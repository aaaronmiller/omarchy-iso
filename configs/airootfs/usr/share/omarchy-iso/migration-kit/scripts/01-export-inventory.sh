#!/usr/bin/env bash
# Snapshot everything on the Fedora install that the Omarchy plan needs to port.
# Read-only: writes only into ../inventory/. Safe to re-run any time before the wipe.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/inventory"
mkdir -p "$OUT"/{etc,gsettings,systemd-user,hypr}

echo "→ packages"
dnf repoquery --userinstalled --qf '%{name}\n' 2>/dev/null | sort -u >"$OUT/dnf-userinstalled.txt"
dnf repolist 2>/dev/null >"$OUT/dnf-repos.txt"
flatpak list --app --columns=application 2>/dev/null | sort -u >"$OUT/flatpaks.txt"
ls ~/.npm-global/lib/node_modules 2>/dev/null >"$OUT/npm-global.txt"
ls ~/.bun/install/global/node_modules 2>/dev/null >"$OUT/bun-global.txt"
ls ~/.cargo/bin 2>/dev/null >"$OUT/cargo-bin.txt"
ls ~/.local/bin 2>/dev/null >"$OUT/local-bin.txt"
ls ~/go/bin 2>/dev/null >"$OUT/go-bin.txt"
ollama list 2>/dev/null >"$OUT/ollama-models.txt"

echo "→ GNOME input/display settings"
for schema in org.gnome.desktop.peripherals.touchpad org.gnome.desktop.peripherals.mouse \
  org.gnome.desktop.peripherals.keyboard org.gnome.desktop.input-sources org.gnome.desktop.interface \
  org.gnome.mutter org.gnome.desktop.wm.keybindings org.gnome.settings-daemon.plugins.media-keys; do
  gsettings list-recursively "$schema" >"$OUT/gsettings/$schema.txt" 2>/dev/null
done
cp -f ~/.config/monitors.xml "$OUT/gsettings/" 2>/dev/null

echo "→ system tweaks"
for f in /etc/libinput/local-overrides.quirks /etc/sysctl.d/99-btrfs.conf /etc/sysctl.d/99-performance.conf \
  /etc/udev/rules.d/70-uinput.rules /etc/udev/rules.d/80-dotool.rules /etc/iptsd.conf; do
  [[ -r $f ]] && cp -f "$f" "$OUT/etc/$(basename "$f")"
done
systemctl cat surface-rapl-tweak.service >"$OUT/etc/surface-rapl-tweak.service" 2>/dev/null
cat /proc/cmdline >"$OUT/etc/kernel-cmdline.txt"
systemctl list-unit-files --state=enabled --no-legend >"$OUT/systemd-system-enabled.txt" 2>/dev/null

echo "→ user services"
systemctl --user list-unit-files --state=enabled --no-legend >"$OUT/systemd-user-enabled.txt" 2>/dev/null
for u in ~/.config/systemd/user/*.service ~/.config/systemd/user/*.timer; do
  [[ -f $u && ! -L $u ]] && cp -f "$u" "$OUT/systemd-user/"
done

echo "→ hyprland (old hyprlang config, for translation reference)"
cp -f ~/.config/hypr/hyprland.conf ~/.config/hypr/hypridle.conf "$OUT/hypr/" 2>/dev/null

echo "→ hardware facts"
{
  echo "product: $(cat /sys/class/dmi/id/product_name)"
  echo "kernel:  $(uname -r)"
  for v in /sys/class/video4linux/*; do echo "camera:  $(basename "$v") = $(cat "$v/name")"; done
  ls -l /dev/v4l/by-path/ 2>/dev/null | sed 's/^/by-path: /'
  for e in /sys/class/input/event*; do
    n=$(cat "$e/device/name" 2>/dev/null)
    [[ $n == *Surface* || $n == *Touchpad* || $n == *Mouse* ]] && echo "input:   $(basename "$e") = $n"
  done
} >"$OUT/hardware.txt"

echo "→ git repos with unpushed or uncommitted work (fix these before wiping)"
: >"$OUT/git-dirty.txt"
while IFS= read -r g; do
  r=$(dirname "$g")
  s=$(git -C "$r" status --porcelain 2>/dev/null | wc -l)
  a=$(git -C "$r" rev-list --count '@{u}..HEAD' 2>/dev/null || echo "no-upstream")
  [[ $s != 0 || $a != 0 ]] && echo "$r  dirty=$s ahead=$a" >>"$OUT/git-dirty.txt"
done < <(fd -H -t d '^\.git$' ~/code ~/surface-dots 2>/dev/null)

echo "done → $OUT"
