#!/usr/bin/env bash
# Add the optional extra tools any time after install.
#   50-extras.sh --list            show extras and whether each is installed
#   50-extras.sh yazi atuin ...    install the named ones
#   50-extras.sh --all             install every extra (AUR ones included)
#   50-extras.sh --pick            choose from a numbered list
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mapfile -t OFF < <(grep -v '^#' "$ROOT/packages/extras-official.txt" | grep -v '^$')
mapfile -t AUR < <(grep -v '^#' "$ROOT/packages/extras-aur.txt" | grep -v '^$')
ALL=("${OFF[@]}" "${AUR[@]}")
is_aur() { local x; for x in "${AUR[@]}"; do [[ $x == "$1" ]] && return 0; done; return 1; }
known() { local x; for x in "${ALL[@]}"; do [[ $x == "$1" ]] && return 0; done; return 1; }

install_list() {
  local o=() a=() p
  for p in "$@"; do known "$p" || { echo "not an extra: $p (see --list)" >&2; exit 2; }; if is_aur "$p"; then a+=("$p"); else o+=("$p"); fi; done
  ((${#o[@]})) && omarchy-pkg-add "${o[@]}"
  ((${#a[@]})) && omarchy-pkg-aur-add "${a[@]}"
  return 0
}

case "${1:---list}" in
  --list) for p in "${ALL[@]}"; do s=no; pacman -Q "$p" >/dev/null 2>&1 && s=yes; printf '%-16s %-4s installed=%s\n' "$p" "$(is_aur "$p" && echo AUR || echo repo)" "$s"; done ;;
  --all) install_list "${ALL[@]}" ;;
  --pick)
    select p in "${ALL[@]}" DONE; do [[ $p == DONE || -z ${p:-} ]] && break; chosen+=("$p"); echo "queued: ${chosen[*]}"; done
    ((${#chosen[@]})) && install_list "${chosen[@]}" ;;
  *) install_list "$@" ;;
esac
