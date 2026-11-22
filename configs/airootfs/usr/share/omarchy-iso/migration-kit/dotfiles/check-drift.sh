#!/usr/bin/env bash
# From thehumanx/omarchy-setup (post-update hook idea): after an Omarchy update, check that our overlay is still in place.
# Warns only. It never fixes anything on its own; re-run ./install.sh --apply if something drifted.
set -u
cd "$(dirname "$0")" || exit 1
TARGET=${TARGET:-$HOME}
bad=0

while IFS= read -r -d '' f; do
  rel=${f#hosts-surface/}
  rel=${rel#shared/}
  t="$TARGET/$rel"
  if [[ -L $t ]]; then
    [[ -e $t ]] || { echo "BROKEN LINK  $t"; bad=1; }
  else
    echo "NOT A LINK   $t (Omarchy may have rewritten it)"; bad=1
  fi
done < <(find shared hosts-surface \( -type f -o -type l \) -print0 2>/dev/null)

grep -qxF 'config-file = ?surface.conf' "$TARGET/.config/ghostty/config" 2>/dev/null \
  || { echo "MISSING LINE  ghostty config no longer includes surface.conf"; bad=1; }

if [[ $bad -eq 0 ]]; then echo "overlay intact"; else echo "drift found: run ./install.sh --apply"; fi
exit $bad
