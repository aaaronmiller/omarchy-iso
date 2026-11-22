# Switching appearance on Omarchy: what is live, and what is not

Status key: TESTED = run on real hardware or tooling today. SOURCE = read in the Omarchy/Noctalia source or docs only.
UNTESTED = written but never run on Omarchy. Nothing below has been run on an Omarchy session yet.

| Change | Live, no logout? | How | Status |
|---|---|---|---|
| Omarchy theme (colours, wallpaper, terminal, btop, GTK...) | Yes | Super+Shift+Ctrl+Space (visual picker) or `omarchy theme set <name>` | SOURCE (Omarchy release notes) |
| Noctalia colours following the theme | Yes | the theme-set hook (`configs/omarchy-hooks`) writes Noctalia's palette; Noctalia reloads with `noctalia msg config-reload` | SOURCE + palette script tested on 24 themes |
| Desktop shell: Omarchy shell <-> Noctalia | Yes (no logout) | `shell-switch noctalia` / `shell-switch omarchy`: stops one shell, swaps the keybindings via `hyprctl reload`, starts the other | UNTESTED. Script reviewed, never run on Omarchy |
| Wallpaper | Yes | Super+Ctrl+Space (Omarchy background switcher) | SOURCE |
| Terminal look (Ghostty) | Yes | Ghostty reloads its config with its own reload key; theme follows the Omarchy theme | SOURCE |
| Window manager / compositor (Hyprland <-> niri, sway...) | NO | A compositor owns the whole session, so changing it needs a new login session | not possible live |

## Closest thing to a live compositor swap
Install the other compositor's session, then switch at the login screen (or log out and pick the session). Noctalia v5 runs on
Hyprland, niri, sway, labwc and others, so the shell, theme and palette setup stay the same across them. This is "as close as
possible": one login, not a rebuild. It is not implemented or tested here.

## Caveats found in research
- Third-party Quickshell plugins that use a bare `Color.` break on Qt 6.12; check research/CONSOLIDATED-REPORT.md before installing any plugin.
- A GUI-written `[theme]` in Noctalia's state `settings.toml` overrides the hook's `config.toml`. The hook does not yet create
  `config.toml` if it is missing or warn about the state file (open item).
- After every `omarchy update`, run `dotfiles/check-drift.sh`; Omarchy migrations can rewrite files that the overlay links.
