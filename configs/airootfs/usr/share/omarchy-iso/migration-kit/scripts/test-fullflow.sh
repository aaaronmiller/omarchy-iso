#!/usr/bin/env bash
# End-to-end run of 00-postinstall.sh --auto with every system command stubbed. Nothing outside a temp HOME is touched:
# sudo, pacman, pacman-key, omarchy-*, limine-*, lsmod, etc. are stubs that only log. Real: bash, stow, gpg, curl (signing-key
# fingerprint check hits the network), find over /boot (host must have a *surface* boot image, as the Surface laptop does).
set -u
KIT="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d "${CLAUDE_JOB_DIR:-$HOME/.cache}/fullflow.XXXX")
mkdir -p "$T/bin" "$T/home" "$T/state"
LOG=$T/calls.log; : >"$LOG"
pass=0; fail=0
chk() { if eval "$2"; then echo "PASS $1"; pass=$((pass+1)); else echo "FAIL $1"; fail=$((fail+1)); fi; }

stub() { printf '#!/bin/sh\necho "%s $*" >>"%s"\n%s\n' "$1" "$LOG" "${2:-exit 0}" >"$T/bin/$1"; chmod +x "$T/bin/$1"; }
# sudo: log, drain stdin (for `| sudo tee`), never execute, except read-only `find`.
printf '#!/bin/sh\necho "sudo $*" >>"%s"\n[ "$1" = find ] && exec "$@"\n[ -t 0 ] || cat >/dev/null\nexit 0\n' "$LOG" >"$T/bin/sudo"; chmod +x "$T/bin/sudo"
for c in pacman-key omarchy-snapshot omarchy-pkg-drop omarchy-pkg-add omarchy-pkg-aur-add limine-mkinitcpio notify-send systemctl udevadm; do stub $c; done
stub lsmod 'printf "surface_hid 1 0\nsurface_aggregator 1 0\npinctrl_tigerlake 1 0\n"'
stub pacman 'case "$*" in "-Q linux-surface"*) [ -e "'$T'/no-surface" ] && exit 1; exit 0;; "-Si qt6-declarative"*) echo "Version         : 6.11.2-1";; "-Q omarchy"*) echo "omarchy 4.0.4-1";; esac; exit 0'
stub journalctl '[ -e "'$T'/no-watch" ] || echo "Watching /dev/input/event17 (IPTSD Virtual Touchscreen)"'
stub omarchy 'case "$*" in "hook --help") exit 0;; esac; exit 0'

export WAIT_SECONDS=3 PATH="$T/bin:$PATH" HOME="$T/home" STATE_DIR="$T/state" AUTOSTART_FILE="$T/autostart.desktop" KERNEL_RELEASE=6.19.8-surface
cd "$T" || exit 1

echo "--- run 1: --auto on the Surface kernel"
bash "$KIT/scripts/00-postinstall.sh" --auto </dev/null >"$T/run1.txt" 2>&1; rc=$?
chk "run 1 exits 0 (rc=$rc)" "[[ $rc == 0 ]]"
[[ $rc == 0 ]] || tail -20 "$T/run1.txt"
chk "tweaks step ran" "grep -q 'sudo install -Dm644 .*local-overrides.quirks' $LOG"
chk "initramfs modules written" "grep -q 'zz-surface-laptop4.conf' $LOG"
chk "boot order written" "grep -q 'zz-surface-boot-order.conf' $LOG"
chk "no full system upgrade on the Surface kernel" "! grep -q 'pacman -Syu' $LOG && grep -q 'sudo pacman -S --needed linux-surface' $LOG"
chk "signing key imported only after fingerprint check" "grep -q 'pacman-key --add' $LOG && grep -q 'pacman-key --lsign-key' $LOG"
chk "migration marker created" "grep -q 'var/lib/omarchy/migrations/1789325478' $LOG"
chk "snapshot taken before stock kernels dropped" "[[ \$(grep -n 'omarchy-snapshot create' $LOG | cut -d: -f1) -lt \$(grep -n 'omarchy-pkg-drop' $LOG | cut -d: -f1) ]]"
chk "stock kernels dropped" "grep -q 'omarchy-pkg-drop linux linux-headers linux-omarchy linux-omarchy-headers' $LOG"
chk "official packages installed" "grep -q 'omarchy-pkg-add stow git-delta podman' $LOG"
chk "AUR packages installed" "grep -q 'omarchy-pkg-aur-add lazysql-bin zsh-fast-syntax-highlighting' $LOG"
chk "default tools installed" "grep -q 'omarchy-pkg-add .*yazi.*atuin.*gitui.*helix' $LOG"
chk "held-back extras NOT installed in auto mode" "! grep -qE 'omarchy-pkg(-aur)?-add .*(television|rtk-bin|codewhale)' $LOG"
chk "optional media pkgs NOT installed" "! grep -q 'yt-dlp' $LOG"
chk "dotfiles linked into HOME" "[[ -L $HOME/.config/hypr/input.lua ]]"
chk "ghostty surface.conf linked" "[[ -L $HOME/.config/ghostty/surface.conf ]]"
chk "ghostty config includes surface.conf once" "[[ \$(grep -c 'config-file = ?surface.conf' $HOME/.config/ghostty/config) == 1 ]]"
chk "palette hook installed" "[[ -x $HOME/.config/omarchy/hooks/noctalia-palette.py ]] && grep -q 'omarchy hook install theme-set' $LOG"
chk "summary written" "[[ -s $KIT/reports/postinstall-summary.md ]]"
chk "state records every step" "[[ \$(sort -u $STATE_DIR/state | tr '\n' ' ') == 'dotfiles finalized hook packages tweaks twofinger ' ]]"

echo "--- run 2: nothing is repeated"
: >"$LOG"
bash "$KIT/scripts/00-postinstall.sh" --auto </dev/null >"$T/run2.txt" 2>&1
chk "second run installs nothing" "! grep -qE 'omarchy-pkg|pacman|snapshot' $LOG"
chk "second run says already done" "grep -c 'already' $T/run2.txt | grep -qE '^[4-9]|^[1-9][0-9]'"

echo "--- run 3: --include-optional adds the opt-in packages"
rm -- "$STATE_DIR/state"; : >"$LOG"
bash "$KIT/scripts/00-postinstall.sh" --auto --include-optional --no-finalize </dev/null >"$T/run3.txt" 2>&1
chk "extras installed with --include-optional" "grep -q 'television' $LOG && grep -q 'rtk-bin' $LOG"
chk "--no-finalize keeps the stock kernel" "! grep -q 'omarchy-pkg-drop' $LOG"

echo "--- run 4: stock kernel -> stage 1, resume entry, no reboot without --reboot"
rm -f -- "$STATE_DIR/state" "$AUTOSTART_FILE"; : >"$LOG"
touch "$T/no-surface"
KERNEL_RELEASE=6.19.0-arch1 bash "$KIT/scripts/00-postinstall.sh" --auto </dev/null >"$T/run4.txt" 2>&1; rc=$?
rm -f -- "$T/no-surface"
chk "stage 1 exits 0 (rc=$rc)" "[[ $rc == 0 ]]"
chk "stage 1 installs the Surface kernel" "grep -q 'sudo pacman -Syu --needed linux-surface' $LOG"
chk "stage 1 recorded" "grep -qx stage1 $STATE_DIR/state"
chk "resume entry written" "[[ -s $AUTOSTART_FILE ]] && grep -q 'launch-terminal.sh .*00-postinstall.sh --resume' $AUTOSTART_FILE"
chk "no packages before the reboot" "! grep -q 'omarchy-pkg' $LOG"
chk "no reboot without --reboot" "! grep -q 'systemctl reboot' $LOG"

echo "--- run 5: after the reboot, --resume disarms the entry and finishes"
: >"$LOG"
KERNEL_RELEASE=6.19.8-surface bash "$KIT/scripts/00-postinstall.sh" --resume </dev/null >"$T/run5.txt" 2>&1; rc=$?
chk "resume exits 0 (rc=$rc)" "[[ $rc == 0 ]]"
chk "resume entry removed" "[[ ! -e $AUTOSTART_FILE ]]"
chk "resume ran tweaks, finalize, packages" "grep -q zz-surface-laptop4 $LOG && grep -q omarchy-pkg-drop $LOG && grep -q 'omarchy-pkg-add stow' $LOG"

echo "--- run 6: a failing step is reported and exits non-zero"
rm -f -- "$STATE_DIR/state"; : >"$LOG"
printf '#!/bin/sh\necho "omarchy-pkg-add $*" >>"%s"\nexit 1\n' "$LOG" >"$T/bin/omarchy-pkg-add"
KERNEL_RELEASE=6.19.8-surface bash "$KIT/scripts/00-postinstall.sh" --auto </dev/null >"$T/run6.txt" 2>&1; rc=$?
chk "failing packages step: exit non-zero" "[[ $rc != 0 ]]"
chk "failure named in output" "grep -q 'FAILED STEPS.*packages' $T/run6.txt"
chk "failed step not marked done" "! grep -qx packages $STATE_DIR/state"
chk "later steps still ran" "grep -qx dotfiles $STATE_DIR/state"

echo "--- run 7: two-finger click installs when healthy, rolls back when not"
rm -f -- "$STATE_DIR/state"; : >"$LOG"
printf '#!/bin/sh\necho "omarchy-pkg-add $*" >>"%s"\nexit 0\n' "$LOG" >"$T/bin/omarchy-pkg-add"
bash "$KIT/scripts/00-postinstall.sh" --auto --no-finalize </dev/null >"$T/run7.txt" 2>&1; rc=$?
chk "healthy: run exits 0 (rc=$rc)" "[[ $rc == 0 ]]"
chk "healthy: python-evdev installed" "grep -q 'omarchy-pkg-add python-evdev' $LOG"
chk "healthy: root-owned script installed" "grep -q 'sudo install -Dm755 -o root -g root .*two-finger-right-click.py /usr/local/lib/surface-fixes' $LOG"
chk "healthy: unit written and started" "grep -q 'sudo tee /etc/systemd/system/two-finger-rightclick.service' $LOG && grep -q 'systemctl enable --now two-finger-rightclick.service' $LOG"
chk "healthy: step recorded" "grep -qx twofinger $STATE_DIR/state"
chk "installed by default in auto mode (no --include-optional needed)" "grep -qx twofinger $STATE_DIR/state"
rm -f -- "$STATE_DIR/state"; : >"$LOG"; touch "$T/no-watch"
bash "$KIT/scripts/00-postinstall.sh" --auto --no-finalize </dev/null >"$T/run8.txt" 2>&1; rc=$?
rm -f -- "$T/no-watch"
chk "unhealthy: reported as failed step" "grep -q 'FAILED STEPS.*twofinger' $T/run8.txt && [[ $rc != 0 ]]"
chk "unhealthy: rolled back (unit removed)" "grep -q 'sudo rm -f -- /etc/systemd/system/two-finger-rightclick.service' $LOG"
chk "unhealthy: not marked done" "! grep -qx twofinger $STATE_DIR/state"

echo "--- run 9: Qt guard (old omarchy + Qt 6.12 offered) skips packages and says so"
rm -f -- "$STATE_DIR/state"; : >"$LOG"
stub pacman 'case "$*" in "-Q linux-surface"*) exit 0;; "-Si qt6-declarative"*) echo "Version         : 6.12.0-1";; "-Q omarchy"*) echo "omarchy 4.0.4-1";; esac; exit 0'
stub omarchy-pkg-add
bash "$KIT/scripts/00-postinstall.sh" --auto --no-finalize </dev/null >"$T/run9.txt" 2>&1; rc=$?
chk "guard: no packages installed" "! grep -q 'omarchy-pkg-add stow' $LOG"
chk "guard: step reported failed, not done" "grep -q 'FAILED STEPS.*packages' $T/run9.txt && ! grep -qx packages $STATE_DIR/state && [[ $rc != 0 ]]"
stub pacman 'case "$*" in "-Q linux-surface"*) exit 0;; "-Si qt6-declarative"*) echo "Version         : 6.12.0-1";; "-Q omarchy"*) echo "omarchy 4.0.5-1";; esac; exit 0'
rm -f -- "$STATE_DIR/state"; : >"$LOG"
bash "$KIT/scripts/00-postinstall.sh" --auto --no-finalize </dev/null >"$T/run10.txt" 2>&1; rc=$?
chk "guard: omarchy 4.0.5 + Qt 6.12 installs normally" "grep -q 'omarchy-pkg-add stow' $LOG && [[ $rc == 0 ]]"

rm -f -- "$KIT/reports/postinstall-summary.md"
echo "pass=$pass fail=$fail (temp: $T)"
[[ $fail == 0 ]]
