#!/usr/bin/env bash
# Helpers for the dotfiles overlay. Each one is a small idea taken from a reviewed repo (see README.md for provenance).

STAMP=${STAMP:-$(date +%Y%m%d-%H%M%S)}

say() { printf '[dotfiles] %s\n' "$*"; }

# From Zeus-Deus/omarchy-setup: move an existing file aside with a timestamp, only when its content differs.
# A symlink that already points at our package is left alone.
backup_if_differs() {
  local target=$1 source=$2
  [[ -e $target || -L $target ]] || return 0
  if [[ -L $target ]]; then
    [[ $(readlink -f "$target") == "$(readlink -f "$source")" ]] && return 0
  elif [[ -f $target ]] && cmp -s "$target" "$source"; then
    mv -- "$target" "$target.same-$STAMP"      # identical: still move aside so stow can link it
    return 0
  fi
  mv -- "$target" "$target.bak-$STAMP"
  say "backed up $target -> $target.bak-$STAMP"
}

# From LinuxBeginnings/Hyprland-Dots patch contract: idempotent, edits one setting, never rewrites the file.
# Appends LINE to FILE only if that exact line is missing. Creates the file's directory, never the user's other content.
ensure_line() {
  local file=$1 line=$2
  mkdir -p "$(dirname "$file")"
  [[ -f $file ]] || : > "$file"
  if grep -qxF -- "$line" "$file"; then
    return 0
  fi
  [[ -f $file.pre-dotfiles ]] || cp -- "$file" "$file.pre-dotfiles"   # one pristine copy, for undo
  printf '%s\n' "$line" >> "$file"
  say "appended to $file: $line"
}
