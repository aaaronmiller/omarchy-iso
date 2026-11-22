#!/usr/bin/env bash
# Post-install overlay for the Surface Laptop 4 on Omarchy. Run AFTER the Omarchy install and 10-omarchy-surface.sh.
# Uses Omarchy's own helpers (omarchy-pkg-add / omarchy-pkg-aur-add) and never edits /usr/share/omarchy.
# Package names verified against archlinux.org and the AUR RPC on 2026-10-17.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/lib-auto.sh

# Package lists live in packages/*.txt (one per line, verified 2026-10-17). Edit there, not here.
mapfile -t PACMAN_PKGS < <(grep -v '^#' packages/pacman-official.txt | grep -v '^$')
mapfile -t AUR_PKGS < <(grep -v '^#' packages/aur.txt | grep -v '^$')
mapfile -t OPTIONAL_AUR < <(grep -v '^#' packages/aur-optional.txt | grep -v '^$')
mapfile -t EXTRA_PACMAN < <(grep -v '^#' packages/extras-official.txt | grep -v '^$')
mapfile -t EXTRA_AUR < <(grep -v '^#' packages/extras-aur.txt | grep -v '^$')

# Opt-in, NOT default: yt-dlp goes beyond YouTube's official API terms; use only for content you own.
OPTIONAL_OFFICIAL=(yt-dlp ffmpeg)

# Optional, opt-in only. Noctalia v5 ships as 'noctalia' in Arch [extra] — see 30-desktop.sh, not the AUR.

echo "→ Qt 6.12 guard (omarchy #14469/#15069/#15265/#14553): Qt ≥6.12 + omarchy ≤4.0.4 + unpatched shell = black bar."
echo "   Status 2026-10-18: omarchy 4.0.5 (released 2026-10-18 02:50 UTC) has the fix (#14553, backport #15265 closed); the stable mirror serves Qt 6.12.0."
echo "   Third-party plugins that use a bare 'Color.' still break on Qt 6.12 (#14597 open): audit them before installing."
qtv=$(pacman -Si qt6-declarative 2>/dev/null | awk -F': ' '/^Version/{print $2}' || true); omv=$(pacman -Q omarchy 2>/dev/null | awk '{print $2}' || true)
if [[ $qtv == 6.12* && $omv == 4.0.[0-4]-* ]]; then
  echo "   BLOCKED: the mirror offers Qt $qtv but omarchy $omv has no Commons.Color fix. Run 'omarchy update' (4.0.5+) first, then re-run this script."
  # Exit 3 = skipped, not done: 00-postinstall.sh records a failure instead of marking the step complete.
  confirm_risky "   Continue with package installs anyway (skips system upgrade)?" || { echo "   Packages skipped by the Qt guard." >&2; exit 3; }
fi

echo "Official repo packages:"; printf '  %s\n' "${PACMAN_PKGS[@]}"
confirm "Install these with omarchy-pkg-add?" || exit 0
omarchy-pkg-add "${PACMAN_PKGS[@]}"

echo "Optional official packages: ${OPTIONAL_OFFICIAL[*]} (media codecs; skip if you don't need them)"
confirm_optional "Install these too with omarchy-pkg-add?" && omarchy-pkg-add "${OPTIONAL_OFFICIAL[@]}" || true

echo "AUR packages:"; printf '  %s\n' "${AUR_PKGS[@]}"
confirm "Install AUR packages with omarchy-pkg-aur-add?" && omarchy-pkg-aur-add "${AUR_PKGS[@]}" || true

echo "Extra tools (open decision D4, not vetted as defaults): ${EXTRA_PACMAN[*]} / ${EXTRA_AUR[*]}"
confirm_optional "Install the extra official tools?" && omarchy-pkg-add "${EXTRA_PACMAN[@]}" || true
confirm_optional "Install the extra AUR tools?" && omarchy-pkg-aur-add "${EXTRA_AUR[@]}" || true

if ((${#OPTIONAL_AUR[@]})); then
  confirm_optional "Also install ${OPTIONAL_AUR[*]}?" && omarchy-pkg-aur-add "${OPTIONAL_AUR[@]}" || true
fi

echo "Done. Next: stow the overlay (scripts/ and configs/ in the dotfiles repo), then check 'wt --version' (binary name)."
