#!/usr/bin/env bash
# Run on OMARCHY after first boot (from a clone of this folder). DRAFT: untested on target.
#
#   ./10-omarchy-surface.sh            stage 1: add linux-surface + iptsd, port Surface tweaks, reboot
#   ./10-omarchy-surface.sh --tweaks   already on linux-surface (custom ISO): repo, initramfs modules, boot order, Surface fixes, no prompt
#   ./10-omarchy-surface.sh --finalize stage 2: once booted on linux-surface, REMOVE the stock kernel
#
# No stock-kernel fallback is kept: without the Surface Aggregator drivers the
# Laptop 4's keyboard and touchpad don't work, so that entry is useless. Recovery
# instead = Limine snapshots, the Fedora entry (until Phase 8), the Omarchy USB.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FPR=87DEFA4AB94A99A4C8C3112556C464BAAC421453 # linux-surface key, verified 2026-10-17
STOCK_KERNELS=(linux linux-headers linux-omarchy linux-omarchy-headers)
source "$(dirname "$0")/lib-auto.sh"

# Block Omarchy migration 1789325478: it installs linux-omarchy and demotes linux-surface in BOOT_ORDER
# on any non-T2 x86 machine that lacks its marker (round 3 research, migration source at ff85faf8).
sudo install -Dm644 /dev/null /var/lib/omarchy/migrations/1789325478
touch ~/.local/state/omarchy/migrations/1789325478.sh 2>/dev/null || true

if [[ ${1:-} == --finalize ]]; then
  [[ $(uname -r) == *surface* ]] || { echo "Not running linux-surface ($(uname -r)). Boot it first." >&2; exit 1; }
  # Laptop 4: keyboard AND touchpad go through surface_hid (surface_kbd is for older models, not loaded here).
  for chk in "keyboard/touchpad:surface_hid" "aggregator:surface_aggregator"; do
    mods=$(lsmod); grep -q "^${chk#*:} " <<<"$mods" || { echo "${chk%%:*} driver ${chk#*:} not loaded — not removing anything." >&2; exit 1; }
  done
  pacman -Q linux-surface >/dev/null
  # Never remove the stock kernel without a bootable Surface image on disk: limine-mkinitcpio can
  # exit 0 after a failed build (linux-surface report, omarchy #7111 / #8151).
  # Capture first, test after: `find | grep -q` dies of SIGPIPE under pipefail even when it matched. sudo because the ESP is root-only.
  boot_img=$(sudo find /boot /efi /boot/efi -iname '*surface*' 2>/dev/null | head -n1 || true)
  [[ -n $boot_img ]] || { echo "No linux-surface boot image found under /boot or /efi. Not removing anything." >&2; exit 1; }

  confirm "Snapshot, then remove stock kernel(s) ${STOCK_KERNELS[*]}?" || exit 0
  omarchy-snapshot create
  omarchy-pkg-drop "${STOCK_KERNELS[@]}" # Omarchy's own helper; ignores ones not installed
  sudo limine-mkinitcpio || { echo "limine-mkinitcpio failed; stock kernel kept." >&2; exit 1; } # rebuild UKIs + entries so only linux-surface (+ snapshots, Fedora) remain
  echo "Done. Limine should now list only linux-surface, its snapshots, and Fedora."
  exit 0
fi

TWEAKS_ONLY=0; [[ ${1:-} == --tweaks ]] && TWEAKS_ONLY=1
((TWEAKS_ONLY)) || confirm "Install linux-surface kernel + port Surface tweaks?" || exit 0

echo "→ linux-surface signing key (fingerprint checked, not just trusted)"
asc=$(mktemp)
curl -fsSL https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc -o "$asc"
got=$(gpg --show-keys --with-colons "$asc" | awk -F: '/^fpr/{print $10; exit}')
[[ $got == "$FPR" ]] || { echo "FINGERPRINT MISMATCH: $got" >&2; exit 1; }
sudo pacman-key --add "$asc"
rm -f -- "$asc"
sudo pacman-key --lsign-key "$FPR"

echo "→ repo via Omarchy's pre-refresh-pacman hook (omarchy refresh pacman rewrites pacman.conf, a hook survives it)"
hook=~/.config/omarchy/hooks/pre-refresh-pacman.d/10-linux-surface
mkdir -p "$(dirname "$hook")"
cat >"$hook" <<'EOF'
#!/bin/bash
grep -q '^\[linux-surface\]' /etc/pacman.conf || printf '\n[linux-surface]\nServer = https://pkg.surfacelinux.com/arch/\n' | sudo tee -a /etc/pacman.conf >/dev/null
EOF
chmod +x "$hook"
"$hook"

echo "→ packages"
# Already on the Surface kernel (ISO install): do not start a full system upgrade just to apply tweaks.
if pacman -Q linux-surface >/dev/null 2>&1; then sudo pacman -S --needed linux-surface linux-surface-headers iptsd libinput-tools v4l-utils
else sudo pacman -Syu --needed linux-surface linux-surface-headers iptsd libinput-tools v4l-utils; fi

echo "→ Surface keyboard/touchpad drivers in the initramfs (needed to type the disk password)"
# Omarchy writes surface_device_modules.conf for x86 Surfaces (tested on Laptop 3 only). Ours is a
# separate zz- drop-in that APPENDS (MODULES+=): omacom/omarchy #7111 — Omarchy's file uses MODULES=
# and wipes modules set by earlier drop-ins. Laptop 4 keyboard+touchpad = surface_hid over SAM.
pin=$(lsmod | awk '/^pinctrl_/{print $1; exit}')
echo "MODULES+=(${pin} surface_aggregator surface_aggregator_registry surface_aggregator_hub surface_hid_core surface_hid intel_lpss_pci 8250_dw)" |
  sudo tee /etc/mkinitcpio.conf.d/zz-surface-laptop4.conf

echo "→ Limine: boot linux-surface FIRST (Omarchy's BOOT_ORDER puts linux-omarchy first; last file read wins)"
echo 'BOOT_ORDER="linux-surface, linux-surface-*, *, *fallback, Snapshots"' |
  sudo tee /etc/limine-entry-tool.d/zz-surface-boot-order.conf

# NOTE: no mem_sleep_default=deep — the Laptop 4 only offers s2idle (/sys/power/mem_sleep), so it was a no-op.

echo "→ Surface fixes: battery watchdog (#2303), touchscreen-after-resume (#1131), Fedora entry (#7867), iptsd keepalive + touchpad rebind (javon27/omarchy-surface-touch)"
F="$ROOT/configs/surface-fixes"
sudo install -Dm755 "$F/surface-battery-watchdog" /usr/local/bin/surface-battery-watchdog
sudo install -Dm755 "$F/limine-fedora-entry" /usr/local/bin/limine-fedora-entry
# DISABLED (unvetted, see configs/surface-fixes/unvetted/README.md): sudo install -Dm755 "$F/rebind-surface-touchpad.sh" /usr/local/bin/rebind-surface-touchpad
sudo install -Dm644 -t /etc/systemd/system "$F/surface-battery-watchdog.service" "$F/iptsd-resume.service" "$F/limine-fedora-entry.path" "$F/limine-fedora-entry.service"
# DISABLED (unvetted, see configs/surface-fixes/unvetted/README.md): sudo install -Dm644 "$F/iptsd-override.conf" /etc/systemd/system/iptsd.service.d/override.conf
# DISABLED (unvetted, see configs/surface-fixes/unvetted/README.md): sudo install -Dm644 "$F/99-surface-touchpad.rules" /etc/udev/rules.d/99-surface-touchpad.rules

echo "→ libinput quirks (palm + thumb rejection), sysctl, CPU power limits"
sudo install -Dm644 "$ROOT/configs/etc/libinput/local-overrides.quirks" /etc/libinput/local-overrides.quirks
sudo install -Dm644 "$ROOT/configs/etc/sysctl.d/99-performance.conf" /etc/sysctl.d/99-performance.conf
sudo install -Dm644 "$ROOT/configs/etc/systemd/system/surface-rapl-tweak.service" /etc/systemd/system/surface-rapl-tweak.service
sudo systemctl daemon-reload
sudo udevadm control --reload-rules
sudo systemctl enable surface-rapl-tweak.service surface-battery-watchdog.service iptsd-resume.service limine-fedora-entry.path
# DISABLED (unvetted, see configs/surface-fixes/unvetted/README.md): sudo systemctl enable iptsd.service 2>/dev/null || true  # override.conf keeps it alive across hidraw drops
sudo limine-mkinitcpio          # rebuild initramfs/UKIs with the Surface modules + apply BOOT_ORDER
sudo /usr/local/bin/limine-fedora-entry

echo
echo "Reboot → Limine should DEFAULT to linux-surface now. Then check:"
echo "  uname -r                                  # ends in -surface"
echo "  journalctl -b | grep -i quirks            # must NOT say 'Failed to load'"
echo "Keyboard + touchpad + touchscreen all good? →  ./10-omarchy-surface.sh --finalize"
