#!/usr/bin/env bash
# Two-finger tap on the touchscreen = right click (installed by default by 00-postinstall.sh) (reviewed 2026-10-18, see configs/surface-fixes/two-finger-click/README.md).
#   60-two-finger-click.sh              install and start; rolls itself back if the service does not come up healthy
#   60-two-finger-click.sh --uninstall  stop, disable and remove it
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/configs/surface-fixes/two-finger-click"
LIBDIR=/usr/local/lib/surface-fixes
UNIT_NAME=two-finger-rightclick.service
UNIT=/etc/systemd/system/$UNIT_NAME
WAIT_SECONDS="${WAIT_SECONDS:-12}"

[[ $(id -u) != 0 ]] || { echo "Run as your normal user (it uses sudo)." >&2; exit 1; }

remove() {
  sudo systemctl disable --now "$UNIT_NAME" 2>/dev/null || true
  sudo rm -f -- "$UNIT" "$LIBDIR/two-finger-right-click.py"
  sudo systemctl daemon-reload
}

if [[ ${1:-} == --uninstall ]]; then remove; echo "two-finger right-click removed"; exit 0; fi

echo "→ python-evdev"
omarchy-pkg-add python-evdev

echo "→ install (root-owned script, hardened unit)"
sudo install -Dm755 -o root -g root "$SRC/two-finger-right-click.py" "$LIBDIR/two-finger-right-click.py"
sed -e "s/__USER_UID__/$(id -u)/g" -e "s|__LIBDIR__|$LIBDIR|" "$SRC/two-finger-rightclick.service" | sudo tee "$UNIT" >/dev/null
sudo systemctl daemon-reload
sudo systemctl enable --now "$UNIT_NAME"

echo "→ health check (up to ${WAIT_SECONDS}s): service active and the touchscreen found"
ok=0
for ((i = 0; i < WAIT_SECONDS; i++)); do
  sleep 1
  if systemctl is-active --quiet "$UNIT_NAME" && journalctl -u "$UNIT_NAME" -b --no-pager 2>/dev/null | grep -q "Watching /dev/input"; then ok=1; break; fi
done

if ((ok)); then
  echo "OK: two-finger right-click is running. Tap the screen with two fingers in a non-browser app (Chrome/Firefox have their own gesture)."
  echo "Remove: $0 --uninstall"
else
  echo "NOT HEALTHY after ${WAIT_SECONDS}s. Last log lines:" >&2
  journalctl -u "$UNIT_NAME" -b --no-pager 2>/dev/null | tail -15 >&2 || true
  echo "Rolling back." >&2
  remove
  exit 1
fi
