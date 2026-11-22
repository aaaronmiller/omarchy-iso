#!/usr/bin/env bash
# Run a command in whichever terminal exists. Usage: launch-terminal.sh CMD [ARGS...]
# Omarchy ships kitty and alacritty; ghostty arrives with our package list.
set -euo pipefail
[[ $# -gt 0 ]] || { echo "usage: $0 CMD [ARGS...]" >&2; exit 2; }
if command -v xdg-terminal-exec >/dev/null; then exec xdg-terminal-exec "$@"; fi
for t in alacritty ghostty kitty; do
  command -v "$t" >/dev/null || continue
  case $t in
    alacritty) exec alacritty -e "$@" ;;
    ghostty) exec ghostty -e "$@" ;;
    kitty) exec kitty "$@" ;;
  esac
done
echo "no terminal found; run manually: $*" >&2
exit 1
