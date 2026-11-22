# Prompt for the next agent: finish the Fedora → Omarchy move on the Surface Laptop 4

Paste everything below the line into Claude Code / omp / kilo on the machine. Written 2026-10-17 by the agent that did the planning.

---

You're picking up a half-finished OS migration on **a Microsoft Surface Laptop 4** (i7-1185G7, 16 GB, 13.5" 2256×1504, IR camera). Fedora 43 is installed and stays installed for good as the backup OS. Omarchy 4 (Arch + Hyprland) goes alongside it in free space. Your job is to carry the plan through, one phase at a time, checking each step before moving on.

## Read first, in this order
1. `README.md` in this folder: the full plan (phases 0–8), every decision and why, the research, the rollback paths. It's the source of truth. **Read its "Known issues & edge cases" table before Phase 3**; it lists real failures other Surface Laptop 4 / Omarchy users hit, and what this kit does about each.
2. This prompt: current state, hard rules, and what's left.
3. `inventory/`: a snapshot of the Fedora system (packages, GNOME input settings, /etc tweaks, user services, the old hyprlang config, hardware facts).

Where to find this folder:
- Fedora: `~/code/omarchy-migration/`
- USB stick (Ventoy): `omarchy/omarchy-migration/`. Copy it to `~/code/` on the new system before running anything.

## Hard rules: the user is firm on these
- **Surface kernels only, everywhere.** Stock kernels leave the Laptop 4's keyboard and touchpad dead (they need `surface_hid` + `surface_aggregator`), and the wrong kernel getting picked at boot "ALWAYS causes problems". Omarchy keeps no stock-kernel fallback: `scripts/10-omarchy-surface.sh --finalize` removes it. On Fedora, stock kernels are already removed and blocked through `excludepkgs` in `/etc/dnf/dnf.conf`. Never install `linux`, `linux-lts` or Fedora's `kernel`.
- **Fedora is the permanent backup OS.** Never delete or shrink it below 120 GB. There is no "retire Fedora" step.
- **Steering = queue, not pivot.** When the user sends new instructions mid-task, add them to your queue and keep going. An interrupted or rejected tool call while they're typing is steering, not "stop": resume the same step. Only stop or switch on an explicit "stop", "cancel", "skip" or "instead". Finish everything, then list done vs. still queued.
- No `rm -rf`. Destructive commands get a dry run and a question first. Prefer moving things to a backup dir over deleting.
- Always say which terminal a command is for. Their shell is **zsh**: unquoted `$VAR` does NOT word-split (this bit the last agent). Use `xargs`, `${=VAR}` or `bash -c`.
- The user wants minimal explanation and maximum action, and no Windows-style nags.
- Persona: their global CLAUDE.md defines one (an Irish pirate). Keep using it if it's loaded.

## Current state (2026-10-17)

### Already done on Fedora
- **Kernels:** only kernel-surface 6.19.8 (default) and 6.18.8 remain, plus a rescue entry rebuilt from 6.19.8-surface. The linux-surface repo was added (key fingerprint `87DEFA4AB94A99A4C8C3112556C464BAAC421453`). dnf can't see excluded packages, so to remove kernel things later use `--setopt=excludepkgs=`.
- **Touchpad:** `/etc/libinput/local-overrides.quirks` fixed (the old one had invalid keys, which disabled ALL quirks). `libinput quirks validate` passes: palm 80/70, thumb 60/55.
- **CPU power:** `surface-rapl-tweak.service` fixed (it used to write a read-only file, with PL1/PL2 swapped). Now 28 W sustained, 45 W burst. TLP and tuned disabled; power-profiles-daemon + thermald own power.
- **Containers:** `~/containers/arr-suite/compose.yaml` volumes now carry SELinux `:Z`/`:z`. They'd crash-looped about 8,400 times, which is what overheated the laptop.
- **dnf:** the interrupted transaction is repaired, `dnf check` is clean, and the system is fully upgraded. Native Google Chrome 155 is installed alongside the Flatpak.
- **AI tools:** omp + kilo installed and on `opencode-go/muse-spark-1.3-contributor` (small model `deepseek-v4.1-flash`, key in the `OPENCODE_API_KEY` env var), both no-prompt. skillshare syncs `~/code/custom-skills` to 6 agent tools.
- **Bug-report fixes running on Fedora:** `surface-battery-watchdog` (restarts upower after SAM battery timeouts, linux-surface #2303), `iptsd-resume.service` (touchscreen after sleep, #1131), `TLP_ENABLE=0` (TLP's sleep hook was still fighting power-profiles-daemon).
- **Firmware:** Surface UEFI 24.101.143 (Apr 2024); it can't be updated from Linux. If charging stops (ADP1 offline while plugged in, linux-surface #2070): full power cycle, then check the UEFI for a battery-limit toggle.
- **Verified for later:** the IR camera works: `/dev/video2` (by-path `pci-0000:00:14.0-usb-0:6:1.2-video-index0`), greyscale-only 480×480, emitter strobes on alternate frames (about 19/40 lit).
- **Backup:** `~/pre-omarchy-backup/` (also on the USB stick under `omarchy/`) holds git bundles + uncommitted patches + untracked files for 7 repos. See its `RESTORE.md`.

### On the USB stick (Ventoy, NTFS)
- `omarchy-4.0.4.iso`: GPG signature verified (key `40DFB630FF42BCFFB047046CF0134EE680CAC571`)
- `gparted-live-1.8.1-6-amd64.iso`: SHA-256 verified
- `omarchy/`: this kit, the WIP backup, and this prompt

## What's left, in order (details in README)

1. **Phase 1 on Fedora:** reboot first so 6.19.8-surface and the touchpad quirks are live, and confirm the keyboard and touchpad work. Then `BACKUP_DIR=<external> ./scripts/02-preflight-fedora.sh`. Do a full `rsync` of /home (39 GB) to an external drive if the user has one; the USB stick only holds the WIP backup.
2. **Phase 2:** boot GParted from Ventoy and shrink `nvme0n1p3` (btrfs, Fedora) to **120 GiB**, leaving the rest unallocated. Then confirm Fedora still boots.
3. **Phase 3:** Surface UEFI (hold Vol Up + Power) → **Secure Boot off**. Boot Omarchy from Ventoy → **Free space install**, encryption ON. Have a USB keyboard ready for the LUKS prompt. Then run `limine-scan` to add Fedora, with Omarchy as the default entry.
   - If Ventoy fails to boot the Omarchy ISO, try Ventoy's GRUB2 mode (press Ctrl+R in the Ventoy menu); failing that, `dd` the ISO to a separate stick. `grub_memalign: out of memory` → `unable to mount root fs` is omarchy-iso #128, not a bad USB.
   - **If it then boots straight into Fedora**, the installer skipped NVRAM registration (omarchy #10598): run `scripts/03-fix-omarchy-boot-entry.sh` from Fedora.
   - Turn off **Secure Boot only**; keep TPM on unless the installer refuses.
4. **Phase 4:** `scripts/10-omarchy-surface.sh` (it now also sets BOOT_ORDER so linux-surface is the default, appends initramfs modules per omarchy #7111, and installs the battery watchdog, iptsd-resume and the self-healing Fedora Limine entry for omarchy #7867) → reboot into linux-surface → check keyboard, touchpad and touchscreen → `scripts/10-omarchy-surface.sh --finalize`, which removes the stock kernel. Limine must end up with: linux-surface + snapshots + Fedora, nothing else.
5. **Phase 5:** `scripts/30-desktop.sh`: input/monitor Lua configs, Noctalia + `shell-switch`, the Catppuccin theme, and the Noctalia palette bridge hook (`configs/omarchy-hooks/theme-set.d/50-noctalia-palette`, tested on all 24 themes). Add the app theming extras (omacord for Discord via Vesktop, theme-hook-plugin-manager, the IDE theme sync).
6. **Phase 6:** port the stack per the README table: zsh + oh-my-zsh, Ghostty, flatpaks, CLI tools, omp/kilo/skillshare, `~/.claude`, podman arr-suite (`:Z` labels are harmless no-ops on Omarchy, which has no SELinux), user systemd units. Translate the 54 old keybinds from `inventory/hypr/hyprland.conf` into `~/.config/hypr/bindings.lua`. `wallpaper-changer.sh` needs a rewrite (it uses GNOME gsettings).
7. **Phase 7:** face unlock with the plugin `pb3975/omarchy-face-auth` (sudo, polkit and the lock screen; enroll with glasses on AND off), plus `scripts/20-face-login.sh` **step 5 only** for the SDDM login screen. Phase 7c (TPM auto-unlock) is optional and high-risk: do it by hand, after a snapshot.
8. **Dotfiles:** set up a private chezmoi repo as an overlay on Omarchy (see README "Dotfiles"). The user's dotfile edits currently sit inside `~/code/dionysus`, which is SOMEONE ELSE'S public repo (pewdiepie-archdaemon). Move them into the user's own private repo.

## Verify on first Omarchy boot (marked VERIFY in the files)
- `hyprctl configerrors` is clean; `hl.device({...})` and `hl.monitor({...})` are the right Lua syntax
- `noctalia msg --help`: the lock verb (used in `configs/hypr/shell-mode.lua`) and a theme-reload verb (used by the bridge hook)
- the Noctalia config lives at `~/.config/noctalia/config.toml` (the bridge hook assumes this)
- `sudo libinput quirks list /dev/input/eventN` on the touchpad shows the palm and thumb values
- `grep . /sys/class/powercap/intel-rapl:0/constraint_{0,1}_power_limit_uw` reads 28000000 / 45000000

## Still waiting on the user
- Two repos diverged from GitHub with real conflicts: `~/code/aaa-voice-assistant` (49 local vs 56 remote; `.gitignore` + `setup_assistant.py`) and `~/Documents/OBDistGit` (1 vs 12). Local state is saved as branch `backup/local-main-2026-10-17` in each. Ask: merge together, or reset to GitHub?
- Whether to create the private chezmoi dotfiles repo (pushing to GitHub is outward-facing, so confirm the repo name and that it's private).

## Recovery if something breaks
Limine → bootable snapshot (`omarchy-snapshot restore`) · Limine → **Fedora** (always there) · Ventoy stick → Omarchy ISO → `arch-chroot`. There is deliberately no stock-kernel entry.
