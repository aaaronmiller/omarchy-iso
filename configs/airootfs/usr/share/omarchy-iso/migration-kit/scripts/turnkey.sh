#!/usr/bin/env bash
# One command on the freshly installed Omarchy system, run from the Ventoy stick (or anywhere the tarball is):
#   bash /run/media/$USER/Ventoy/omarchy/turnkey.sh
# Extracts the kit to ~/code, then runs 00-postinstall.sh --auto --reboot. After the reboot into linux-surface the
# resume entry reopens the script in a terminal and it finishes finalize, packages, dotfiles and the Noctalia hook.
# Pass --dry-run to see the plan only. Extra flags go straight to 00-postinstall.sh (e.g. --include-optional, --no-finalize).
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tar_file="$here/omarchy-migration-kit.tar.gz"
[[ -f $tar_file ]] || { echo "omarchy-migration-kit.tar.gz not next to this script ($here)" >&2; exit 1; }
[[ $(id -u) != 0 ]] || { echo "Run as your normal user, not root." >&2; exit 1; }

dest="$HOME/code/omarchy-migration"
mkdir -p "$HOME/code"
if [[ -d $dest ]]; then
  stamp=$(date +%Y%m%d-%H%M%S)
  mv -- "$dest" "$dest.old-$stamp"
  echo "existing kit moved to $dest.old-$stamp"
fi
tar xzf "$tar_file" -C "$HOME/code"
chmod +x "$dest"/scripts/*.sh "$dest"/dotfiles/*.sh 2>/dev/null || true

if [[ " $* " == *" --dry-run "* ]]; then exec "$dest/scripts/00-postinstall.sh" --auto "$@"; fi
exec "$dest/scripts/00-postinstall.sh" --auto --reboot "$@"
