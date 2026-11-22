#!/usr/bin/env bash
# Run on OMARCHY: Hyprland configs, Noctalia + switcher, theme, login screen theme, apps.
# DRAFT: untested on target.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$(dirname "$0")/lib-auto.sh"
step() { echo; echo "── $*"; confirm "   run?"; }

if step "Hyprland: input (touchpad/mouse/keyboard) + monitor scale"; then
  for f in input monitors; do
    cp -a ~/.config/hypr/$f.lua ~/.config/hypr/$f.lua.omarchy-default 2>/dev/null || true
    install -m644 "$ROOT/configs/hypr/$f.lua" ~/.config/hypr/$f.lua
  done
  hyprctl reload && hyprctl configerrors
fi

if step "Noctalia v5 + live switcher (Omarchy shell stays the default)"; then
  sudo pacman -S --needed noctalia
  install -Dm755 "$ROOT/configs/shell-switch/bin/omarchy-launch-shell" ~/.local/share/shell-switch/bin/omarchy-launch-shell
  install -Dm755 "$ROOT/configs/shell-switch/bin/shell-switch" ~/.local/bin/shell-switch
  install -m644 "$ROOT/configs/hypr/shell-mode.lua" ~/.config/hypr/shell-mode.lua
  grep -q 'hypr.shell-mode' ~/.config/hypr/hyprland.lua || echo 'require("hypr.shell-mode")' >>~/.config/hypr/hyprland.lua
  echo omarchy >~/.config/shell-mode
  echo "   Try it: shell-switch noctalia   /   shell-switch omarchy"
fi

if step "Theme: Catppuccin (Mocha) everywhere"; then
  # Bridge first, so the theme set below already pushes the palette into Noctalia.
  omarchy hook install theme-set "$ROOT/configs/omarchy-hooks/theme-set.d/50-noctalia-palette"
  omarchy theme set catppuccin || omarchy-theme-set catppuccin
  echo "   Noctalia now follows every Omarchy theme switch (custom palette 'omarchy')."
  echo "   Keep Noctalia's [theme.templates] builtin_ids = [] — Omarchy owns app theming."
fi

if step "Make the remaining apps follow the theme (Discord, Spotify, Zen/Firefox, VS Code)"; then
  echo "   Review each repo before running its installer:"
  echo "   Discord  → install Vesktop, then https://github.com/xPsycho999/omacord"
  echo "   Spotify/Zen/Firefox → https://github.com/OldJobobo/theme-hook-plugin-manager"
  echo "   VS Code  → https://github.com/Keyrxng/Omarchy-IDE-Theme-Sync"
  echo "   Obsidian → Appearance > Themes > Omarchy (one time)"
fi

if step "Login screen theme: sddm-astronaut (Qt6), Catppuccin-matched"; then
  omarchy-pkg-aur-add sddm-astronaut-theme
  sudo install -d /etc/sddm.conf.d
  printf '[Theme]\nCurrent=sddm-astronaut-theme\n' | sudo tee /etc/sddm.conf.d/20-astronaut.conf >/dev/null
  echo "   Pick a variant: sudo nano /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop (ConfigFile=Themes/<name>.conf)"
  echo "   Preview without logging out: sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sddm-astronaut-theme"
  echo "   Revert: sudo rm /etc/sddm.conf.d/20-astronaut.conf && omarchy-refresh-sddm"
fi

if step "Flatpaks from the Fedora inventory"; then
  sudo pacman -S --needed flatpak
  grep -v -E '^org\.gnome\.(Nautilus|TextEditor|Calculator|Loupe|Evince|baobab)$|ExtensionManager' \
    "$ROOT/inventory/flatpaks.txt" | xargs -r flatpak install -y --noninteractive flathub
fi

echo; echo "Next: restore ~/code, dotfiles, and services per README Phase 6."
