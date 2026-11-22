# Dotfiles overlay (Surface Laptop 4 on Omarchy)

One small stow repo that sits on top of Omarchy. It takes one good idea from each repo reviewed and copies none of them whole.
Rule: never edit /usr/share/omarchy. Omarchy-owned files get at most one appended line.

## What was taken from where
| Idea | Source repo | Where it lives here |
|---|---|---|
| Stow with `--no-folding`, a shared package plus a host package, and a `--simulate` dry run by default | 0xRichardH/omarchy-dotfiles | `install.sh` |
| Move a file aside with a timestamp, only when its content differs | Zeus-Deus/omarchy-setup | `lib.sh: backup_if_differs` |
| Idempotent edits that change one setting and never rewrite a file | LinuxBeginnings/Hyprland-Dots | `lib.sh: ensure_line` |
| A post-update check that warns about drift and fixes nothing silently | thehumanx/omarchy-setup | `check-drift.sh` |
| Plain-text package lists, one name per line | groenewege/dotfiles-omarchy | `../packages/*.txt` |
| Host-specific package named for the machine | timmo001/dotfiles (host suffix) | `hosts-surface/` |

Deliberately not taken: curl-pipe-bash installs, `sed -i` on Omarchy scripts, hardcoded usernames, copying whole configs.

## Layout
- `hosts-surface/` Surface-only files. Hyprland Lua files and `shell-switch` are symlinks into `../configs/`, so each file exists once.
  `surface.conf` (Ghostty) is a real file here.
- `shared/` empty for now; files that apply to every machine go here.

## Use
- `./install.sh` dry run. `./install.sh --apply` links (existing files are moved aside as `.bak-<time>`).
- `./check-drift.sh` after each `omarchy update`.

## Tested here (Fedora, throwaway target directory, stow 2.4.1)
Dry run detects conflicts and aborts; apply backs up, links and appends one line; a second apply changes nothing; the drift check
passes when intact and fails when a file is rewritten; the real Ghostty binary validates the resulting config.
Not tested on Omarchy: nothing here has run on an Omarchy session.

## Manager choice
Stow was chosen over chezmoi for fewer moving parts and because DHH recommends it for backing up your own dotfiles (his post on X, 2025). I did not read the manual's dotfiles page itself. omp's sweep leaned toward
chezmoi (see ../../omarchy-iso/research/CONSOLIDATED-REPORT.md); switching later would only touch `install.sh`.
