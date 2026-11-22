# Prompt for the next agent: finish the Fedora → Omarchy move on the Surface Laptop 4

Paste everything below the line into Claude Code on the NEW system (Omarchy side). Current as of 2026-10-18. It replaces the earlier prompt (kept in `archive/`).

---

You are picking up a Fedora 43 → Omarchy 4 migration on a **Microsoft Surface Laptop 4** (i7-1185G7, 16 GB, 2256×1504, IR camera `/dev/video2`). Fedora 43 stays installed for good as the backup OS (120 GiB, never shrink or delete). Omarchy 4 (Arch + Hyprland, Lua configs) is installed from the custom ISO alongside it.

## 0. Rules from the user (non-negotiable)

1. **Surface kernels only.** Never install `linux`, `linux-lts` or Fedora's `kernel`; the keyboard and touchpad need `surface_hid`/`surface_aggregator`. Secure Boot stays OFF.
2. **Steering = queue, not pivot.** New instructions are added to the task queue. Finish everything queued, then list done vs queued.
3. **Evidence before claims.** Never say done/verified/passed without the command output that proves it in the same reply. Every claim in a report carries a source or is tagged UNVERIFIED.
4. **No `rm -rf`.** No wildcards with `rm`. Show the exact target and what is lost before any delete, overwrite, reset or force-push.
5. **Never print or store a secret.** Do not read `~/.secrets` or `~/.buttplug`; copy by path only.
6. **Models:** headless runs and subagents use `claude-sonnet-5-5`. Do not start headless or full-permission sessions the user did not ask for.
7. **Shell:** write multi-line scripts to a file first. Stop processes by recorded PID. Say which terminal each command is for. Minimal explanation, maximum action.

## 1. What was automated for you

The custom ISO carries the Surface kernel, installer fixes and this kit. On a Surface, the installer stages the kit at `/usr/share/omarchy-migration-kit` and adds a one-shot autostart entry. At the first login a terminal opens and runs `scripts/00-postinstall.sh --auto` from `~/code/omarchy-migration`:
- finalize: snapshot, drop the stock kernel (only after the driver and boot-image safety checks), `limine-mkinitcpio`
- packages from `packages/pacman-official.txt` and `aur.txt` (extras are opt-in)
- Surface tweaks (initramfs modules, Limine boot order, power limits, libinput quirks, watchdogs) via `10-omarchy-surface.sh --tweaks`
- dotfiles overlay (`dotfiles/`, stow; existing files moved aside with a timestamp)
- Noctalia palette hook
- a summary at `reports/postinstall-summary.md`

If the autostart did not fire: `~/code/omarchy-migration/scripts/00-postinstall.sh --auto` (or copy the kit from `/usr/share/omarchy-migration-kit` or the Ventoy stick, then `scripts/turnkey.sh`). `--dry-run` shows the plan. State is in `~/.local/state/omarchy-migration/`.

## 2. Your first tasks, in order

1. Read `reports/postinstall-summary.md`. If it is missing, run the script and read its output.
2. Run `scripts/agent-assist.sh run verify-install --agent` (read-only). Fix what it lists, with the user's approval for anything touching /etc or PAM.
3. Check against `docs/TEST-CHECKLIST.md` and the list in §3: `hyprctl configerrors`, `noctalia msg --help` (lock and `config-reload` verbs), touchpad feel, RAPL values, `shell-switch noctalia` / `shell-switch omarchy`.
4. Face login: the user said **yes, with gaze**. `scripts/agent-assist.sh run face-login --agent` (interactive, preflight first, PAM backups, second TTY open).
5. Secrets and repos from the Fedora partition (mounted read-only): `agent-assist.sh run migrate-secrets --agent`, then `restore-repos`. Report; never print contents.
6. Extras on request: `scripts/50-extras.sh --list`. yazi, atuin, gitui and helix are already installed by default. Held back on purpose: rtk-bin and codewhale (they write hooks into agent configs; review first), abtop, walker-bin, television, jujutsu, ast-grep, bottom (herdr and btop already ship with Omarchy).
7. Themes and shells: `dotfiles/APPEARANCE.md` (live switching with `shell-switch`, Omarchy themes feed Noctalia through the palette hook).

## 3. Known facts and hazards (sources in `docs/FINAL-REPORT.md`; open items in `docs/LEDGER.md`)

- **Qt 6.12 hazard:** QML plugins using a bare `Color.` break on Qt 6.12 (omarchy #14597 open). Omarchy 4.0.5 (released 2026-10-18) fixes the shell itself (#14553); the stable mirror now serves Qt 6.12.0 + omarchy 4.0.5. Audit third-party plugins before installing: `agent-assist.sh run audit-plugins --agent`.
- **Migration 1789325478** demotes linux-surface unless `/var/lib/omarchy/migrations/1789325478` exists. The kit creates the marker; confirm it exists.
- **Disabled on purpose:** the unvetted omp Surface fixes in `configs/surface-fixes/unvetted/` (several target USB models, not the Laptop 4).
- **Two-finger right-click:** reviewed 2026-10-18 (`configs/surface-fixes/two-finger-click/README.md`) and installed by default (the user delegated the decision): hardened service, health-checked, rolls itself back if unhealthy. Device detection verified on this hardware; the click injection itself is unverified until the first real test. Remove with `scripts/60-two-finger-click.sh --uninstall`.
- **Noctalia v5** is `noctalia` in Arch `extra` (checked against archlinux.org on 2026-10-18).
- **Touchscreen scroll** in Ghostty and wofi was unexplained on Fedora (Chrome scrolls by touch).
- **Not tested on the laptop:** everything above except what the verify agent reports. Do not claim otherwise.

## 4. Decisions already made by the user
Stow (not chezmoi) for dotfiles; face login yes (gaze); two-finger right-click on by default; yazi/atuin/gitui/helix by default, other extras via `50-extras.sh`; Fedora kept.

## 5. Still the user's to decide
Whether to keep two-finger right-click after testing it; which held-back extras to add; the two diverged and nine dirty repos on Fedora; renewing the OpenAI and OpenCode keys; whether to clear the rofi core dumps on Fedora.

## 6. Recovery
Limine → snapshot (`omarchy-snapshot restore`) · Limine → Fedora (always there) · USB stick → Omarchy ISO → `arch-chroot`. Keep a root TTY open when touching PAM.
