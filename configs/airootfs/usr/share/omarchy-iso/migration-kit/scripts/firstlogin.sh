#!/usr/bin/env bash
# First graphical login on a machine installed from the custom ISO. Started by
# /etc/xdg/autostart/omarchy-migration-firstlogin.desktop, installed as /usr/local/bin/omarchy-migration-firstlogin.
# Copies the baked-in kit to ~/code/omarchy-migration and opens the automated post-install in a terminal.
# It disarms itself before doing anything, so a failure can never loop at every login.
set -uo pipefail
KIT_SRC="${KIT_SRC:-/usr/share/omarchy-migration-kit}"
STATE_DIR="${STATE_DIR:-$HOME/.local/state/omarchy-migration}"
DEST="${DEST:-$HOME/code/omarchy-migration}"
mkdir -p "$STATE_DIR"
[[ -e $STATE_DIR/firstlogin-done ]] && exit 0
date -Is >"$STATE_DIR/firstlogin-done"

[[ -d $KIT_SRC ]] || { echo "no baked-in kit at $KIT_SRC" >>"$STATE_DIR/firstlogin.log"; exit 0; }
if [[ ! -d $DEST ]]; then
  mkdir -p "$(dirname "$DEST")"
  cp -a "$KIT_SRC" "$DEST"
fi

# Let Omarchy's own first-run work (pacman lock, network) settle before we start installing packages.
for _ in $(seq 1 60); do
  if ! pgrep -x pacman >/dev/null && ! pgrep -x yay >/dev/null && ping -c1 -W2 archlinux.org >/dev/null 2>&1; then break; fi
  sleep 5
done

exec "$DEST/scripts/launch-terminal.sh" "$DEST/scripts/00-postinstall.sh" --auto
