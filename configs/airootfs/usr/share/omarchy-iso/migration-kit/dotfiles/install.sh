#!/usr/bin/env bash
# Dotfiles overlay installer for the Surface Laptop 4 on Omarchy.
#   ./install.sh              dry run: show what stow would link (default)
#   ./install.sh --apply      back up conflicting files, then link
# Never edits /usr/share/omarchy. Omarchy-owned files get one appended line at most.
set -euo pipefail
cd "$(dirname "$0")"
# shellcheck source=lib.sh
source ./lib.sh

APPLY=0
[[ ${1:-} == --apply ]] && APPLY=1
TARGET=${TARGET:-$HOME}        # overridable for tests: TARGET=/tmp/x ./install.sh
PACKAGES=(shared hosts-surface)

command -v stow >/dev/null || { echo "stow is not installed (Omarchy: omarchy-pkg-add stow)" >&2; exit 1; }

# Only packages that exist and have content.
use=()
for p in "${PACKAGES[@]}"; do
  [[ -d $p ]] && [[ -n $(find "$p" -mindepth 1 -print -quit) ]] && use+=("$p")
done
[[ ${#use[@]} -gt 0 ]] || { echo "no packages with content in ${PACKAGES[*]}" >&2; exit 1; }

# From 0xRichardH/omarchy-dotfiles: --no-folding so Omarchy's updates and backups never land inside this repo.
STOW=(stow --no-folding -d "$PWD" -t "$TARGET")

if ((!APPLY)); then
  say "dry run (use --apply to change anything). target: $TARGET"
  "${STOW[@]}" -n -v "${use[@]}"
  exit 0
fi

# Move aside regular files that stow would refuse to replace.
for p in "${use[@]}"; do
  while IFS= read -r -d '' f; do
    rel=${f#"$p"/}
    backup_if_differs "$TARGET/$rel" "$f"
  done < <(find "$p" \( -type f -o -type l \) -print0)
done

"${STOW[@]}" -v "${use[@]}"

# Append-only hook into Omarchy's own Ghostty config (the pristine copy is kept as .pre-dotfiles).
ensure_line "$TARGET/.config/ghostty/config" 'config-file = ?surface.conf'

say "done. Run ./check-drift.sh after every 'omarchy update'."
