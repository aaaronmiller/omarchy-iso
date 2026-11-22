# Fedora 43 → Omarchy 4 on the Surface Laptop 4

Plan written 2026-10-17. Target: **Omarchy 4.0.4 "Quattro"** (Arch + Hyprland, Lua configs), **linux-surface** kernel, your touchpad/mouse/keyboard settings ported, **Noctalia v5** as a switchable alternative shell, **Catppuccin** everywhere, and **face login** through the IR camera.

Nothing in this folder has touched the disk yet. Scripts under `scripts/1x-3x` are drafts for the new system and have not run on Omarchy hardware.

**Fedora stays installed permanently as the backup OS.** It's your known-good fallback, and it now boots *only* the surface kernel (see Phase 0). There's no "retire Fedora" phase any more.

---

## STATUS 2026-10-18: read this before the phases below (they predate the research)

Source of truth for current findings: `~/code/omarchy-iso/research/CONSOLIDATED-REPORT.md` (and `LEDGER.md` for open items).

What changed since the plan below was written:
- **Installing:** the custom ISO carries the Surface kernel, installer fixes and this kit. After the install, the first login opens `scripts/00-postinstall.sh --auto` by itself (finalize, packages, dotfiles overlay, Noctalia hook, summary in `reports/`). Manual routes: `scripts/turnkey.sh` from the stick, or `scripts/00-postinstall.sh` (asks first; `--dry-run` shows the plan). Next-agent prompt: `00-NEXT-AGENT-PROMPT.md`; helper agents: `scripts/agent-assist.sh list`; extras: `scripts/50-extras.sh --list`.
- **Phase 7 (face login):** the plugin recommended below, `pb3975/omarchy-face-auth`, is OFF (bare `Color.` breaks on Qt 6.12 and its lock patch no longer applies). Decision 2026-10-18: face login YES, with `gaze` (fits this camera: USB-UVC IR at /dev/video2). Set it up with `scripts/agent-assist.sh run face-login --agent`; `scripts/20-face-login.sh` (Howdy) is superseded.
- **Plugins:** do not install third-party plugins until checked against omp's Qt 6.12 audits (research/recovered-best/omp-rust-sweep/).
- **Dotfiles:** use `dotfiles/` (stow overlay, tested on a throwaway home only). The Phase "Dotfiles" section below is superseded.
- **Removed from this README:** `omarchy-surfacecheck` is not a Surface hardware tool.
- **Surface fixes from omp** (`iptsd` keep-alive, touchpad rebind) are quarantined in `configs/surface-fixes/unvetted/`; they target USB models, not the Laptop 4. Two-finger right-click was reviewed and is installed by default as a hardened, health-checked service: `scripts/60-two-finger-click.sh` (`--uninstall` removes it).
- **Nothing here has been tested on the laptop.** Checklist: `~/code/omarchy-iso/patches/TEST-CHECKLIST.md`.

---

## The short version

| Phase | Where | What | Risk |
|---|---|---|---|
| 0 | Fedora | ✅ Done 2026-10-17: quirks, RAPL, power daemons, surface-only kernels | none |
| 1 | Fedora | Push repos, back up, run preflight | none |
| 2 | GParted (Ventoy) | Secure Boot off → shrink Fedora to 120 GiB (min possible 81 GiB), ~354 GiB free | **medium**: backup first, USB keyboard/mouse |
| 3 | Omarchy USB | Secure Boot off → *free-space* install next to Fedora | low |
| 4 | Omarchy | `10-omarchy-surface.sh`: linux-surface kernel, iptsd, quirks, power → reboot → `--finalize` removes the stock kernel | low |
| 5 | Omarchy | `30-desktop.sh`: input/monitor configs, Noctalia + switcher, theme, SDDM theme, apps | low |
| 6 | Omarchy | Port your stack: zsh, Ghostty, services, containers, AI tools | low |
| 7 | Omarchy | Face unlock plugin (`pb3975/omarchy-face-auth`) for sudo / polkit / lock; `20-face-login.sh` for the SDDM login | **medium**: PAM |
| 7b | Omarchy | Optional TPM auto-unlock so face login is truly hands-free | **high**: initramfs |
| 8 | both | Fedora = permanent backup OS. Keep it updated monthly | none |

**Why dual-boot:** Omarchy's ISO wipes the drive in full-disk mode. You're only using 59 GB of 475 GB, so installing Omarchy beside Fedora costs nothing, and Fedora stays bootable for good as the backup OS. Limine (Omarchy's bootloader) adds Fedora to its menu with `limine-scan`.

**Boot menu rule: surface kernels only, everywhere.** Non-surface kernels leave the Laptop 4's keyboard and touchpad dead, and a stock kernel at the top of GRUB is how the wrong one keeps getting picked. Final Limine menu: **Omarchy (linux-surface)** default · Omarchy snapshots · **Fedora** → Fedora's GRUB with only `kernel-surface` entries.

---

## Phase 0: Fedora fixes ✅ applied 2026-10-17

The survey turned up settings that had been silently broken on Fedora. All are now fixed on Fedora, and the same files port straight to Omarchy. Backups of every replaced file sit beside it as `*.bak-2026-10-17`.

**Kernel hygiene (the wrong-kernel-at-boot problem):**
- Three stock Fedora kernels were installed (6.18.16, 7.0.11, 7.2.11), and 7.2.11 sat at the top of GRUB.
- The linux-surface repo wasn't configured at all, so the surface kernel was stuck at 6.18.8. It's now added at `/etc/yum.repos.d/linux-surface.repo` (key fingerprint verified) → **kernel-surface 6.19.8**.
- `/etc/dnf/dnf.conf` now has `excludepkgs=kernel,kernel-core,kernel-modules*,…`, so dnf can never install a stock kernel again. `kernel-surface*` packages aren't affected.
- ✅ All 15 stock kernel packages removed (and the VM-only `virtualbox-guest-additions` that depended on them). The GRUB **rescue** entry was stock 6.17.1 too; it's rebuilt from 6.19.8-surface, and the old one is parked in `/root/old-stock-rescue/`. GRUB now holds only: 6.19.8-surface (default) · 6.18.8-surface · rescue (6.19.8-surface).
- To remove anything kernel-ish later, note that dnf can't even *see* excluded packages, so use `--setopt=excludepkgs=`.

1. **Palm rejection has never worked.** `/etc/libinput/local-overrides.quirks` contains `AttrScrollFactor` and `AttrPointerAccel`. Those aren't libinput quirk keys, and one unknown key makes libinput throw out *every* quirk:
   ```
   libinput error: Unknown key AttrScrollFactor in [Surface Laptop 4 Touchpad]
   libinput error: Failed to load the device quirks ... This will negatively affect device behavior.
   ```
   The corrected file keeps palm thresholds, adds the **thumb rejection** you asked for, and moves scroll/pointer speed to the compositor config where they belong.
   ✅ Installed. It takes effect at your next log-in; check with `journalctl -b --user | grep -i quirks`, which should show no "Failed to load".
2. **The CPU power tweak has failed on every boot since 2026-05-29.** `surface-rapl-tweak.service` writes `*_max_power_uw`, which is the read-only hardware ceiling, and it also had PL1/PL2 swapped (45 W sustained, 28 W burst). The fixed unit writes `*_power_limit_uw` with 28 W sustained and 45 W burst. Live firmware values right now are 30 W / 60 W.
   ✅ Installed and active. Live limits are now 28 W / 45 W (were 30 W / 60 W), which also means less heat.
3. ✅ **TLP and tuned disabled.** power-profiles-daemon plus thermald own power now, matching Omarchy.
4. ✅ **arr-suite crash loop fixed.** The containers had crash-looped about 8,400 times (100% CPU each, which was the heat) because the compose volumes lacked SELinux labels. `container_t` was denied on `user_home_t`, so the apps had never once written their config. `compose.yaml` now has `:Z` on configs and `:z` on the shared Media/Downloads mounts. On Omarchy (no SELinux) the labels are harmless no-ops.
5. ✅ **Interrupted dnf transaction repaired.** It left 145 duplicate package records; I removed the stale records only (`rpm -e --justdb`), verified the files, and re-ran the upgrade.

---

## Phase 1: backup and preflight (Fedora)

```bash
cd ~/code/omarchy-migration
./scripts/01-export-inventory.sh          # refreshes inventory/ (already run once)
BACKUP_DIR=/run/media/$USER/<drive> ./scripts/02-preflight-fedora.sh
```

Preflight checks that the IR camera returns a frame, that git is clean, that the backup drive has room, and lists secrets to carry by hand.

**Must-do before Phase 2:**
- **8 repos have uncommitted work** (`inventory/git-dirty.txt`): RealtimeSTT, aaa-voice-assistant, agents/…/frontend-design-masterclass (×2), background-maker (*no remote at all*), dionysus (23 files), disable_touchpad_on_typing_linux, terminal-themer (28 files). Your `git-audit-sync` skill is built for this.
- **Full home backup** to an external drive: `/home` is 39 GB. Biggest dirs are `.local` 9.6 G, `.var` (flatpak data) 6.5 G, `.cache` 5.9 G (skippable), `.hermes` 3.2 G.
  ```bash
  rsync -aHAX --info=progress2 --exclude .cache ~/ /run/media/$USER/<drive>/cheta-surface-2026-10-17/
  ```
- **Secrets, separately and encrypted:** `~/.ssh`, `~/.gnupg`, `~/.config/gh`, `~/.hermes`, `~/.openclaw`, KeePassXC DB, keyrings, and the API keys exported in `~/.zshrc`.
- **IR camera verified on this machine (2026-10-17):** `/dev/video2` is greyscale-only 480×480, the emitter strobes on alternate frames (brightness about 70 lit, about 0 unlit), and lit frames give a clean, usable face image. Face unlock will work.
- **Have a USB keyboard handy.** The Laptop 4's built-in keyboard talks through the Surface Aggregator, which has to be in the initramfs to type the disk password at boot. Omarchy's installer adds those modules for x86 Surfaces, but its script prints "Untested Surface Device" for anything except the Laptop 3.

---

## Phase 2: make room (GParted Live from the Ventoy stick)

**Numbers (measured 2026-10-17):** `nvme0n1p3` is 474 GiB btrfs holding the `root` + `home` subvolumes. 67 GiB is used, only 81 GiB is allocated, and the **minimum possible size is 81 GiB** (`btrfs inspect-internal min-dev-size /`). Target **120 GiB** leaves Fedora about 53 GiB of headroom, and Omarchy gets about 354 GiB. Because so little is allocated, the shrink mostly relocates nothing: a few minutes. Want more room for Fedora? 150 GiB works the same way.

**Before you start**
- Plugged into AC. Off-machine copy of `~/pre-omarchy-backup` (already on the stick) and, ideally, a `/home` rsync to an external drive.
- **USB keyboard and mouse** at hand. GParted Live and the Omarchy installer boot non-surface kernels, so the built-in keyboard and touchpad may be dead there.

**Steps**
1. **Secure Boot off first** (also required for Omarchy; Ventoy won't boot ISOs with it on unless you enroll its key). Shut down → hold **Volume Up**, press and release **Power**, keep holding Vol Up until the Surface UEFI appears → **Security → Secure Boot → Disabled** → Exit → Restart now. A red bar on the boot screen from now on is normal. Fedora boots fine with Secure Boot off.
2. **Boot the stick.** Plug in the Ventoy stick, shut down → hold **Volume Down**, press and release **Power**, release Vol Down when the spinning dots appear. Or in the UEFI: **Boot configuration → move USB Storage to the top**.
3. Ventoy menu → `gparted-live-1.8.1-6-amd64.iso` → **Boot in normal mode** → *GParted Live (Default settings)* → keymap: **Don't touch keymap** → language **33** (US English) → mode **0** (start the GUI).
4. In GParted: select **/dev/nvme0n1p3** (btrfs, label `fedora`) → right-click → **Resize/Move**:
   - **New size (MiB): `122880`**
   - **Free space preceding: `0`** (it must stay 0, or GParted *moves* the partition, which is slow and risky)
   - Free space following fills itself in (≈ 362,000 MiB) → **Resize/Move**
5. Click the green ✔ **Apply** → confirm. Wait for "All operations successfully completed".
6. **Leave the new space unallocated.** Don't create a partition; the Omarchy installer wants raw free space.
7. Exit GParted → reboot → **boot Fedora** (normal power-on goes straight to it) and check:
   ```bash
   lsblk /dev/nvme0n1                       # p3 = 120G, ~354G free after it
   sudo btrfs filesystem show /             # devid size 120.00GiB
   uname -r                                  # still 6.19.8-3.surface
   ```
   If Fedora boots normally, Phase 2 is done. UUIDs don't change, so nothing in Fedora needs editing.

**If something goes sideways:** GParted refusing the resize usually means the fs wasn't checked cleanly. Run *Partition → Check* on p3 first, then retry. Never resize while Fedora is hibernated (it isn't; Fedora has no hibernation set up).

---

## Phase 3: install Omarchy

1. ✅ **Already downloaded and verified (2026-10-17)** in `~/Downloads/omarchy-iso/`: `omarchy-4.0.4.iso` (good GPG signature, key `40DFB630FF42BCFFB047046CF0134EE680CAC571`) and `gparted-live-1.8.1-6-amd64.iso` (SHA-256 matches). Write each to a USB stick (two sticks, or one after the other):
   ```bash
   lsblk                                   # find the stick, e.g. /dev/sda — NOT nvme0n1
   sudo dd if=~/Downloads/omarchy-iso/omarchy-4.0.4.iso of=/dev/sdX bs=4M status=progress oflag=sync
   ```
2. Secure Boot is already off from Phase 2 (Omarchy refuses to install with it on). Boot the stick the same way (hold Vol-Down + Power) → Ventoy → `omarchy-4.0.4.iso`. Keep the **USB keyboard** plugged in: the installer is keyboard-driven and runs a non-surface kernel.
3. Boot the USB → answer the questions → choose the NVMe → **Free space install**. Keep encryption **on**.
4. First boot: Limine → disk password → you're auto-logged into Hyprland.
5. **If the laptop boots straight into Fedora** after the install, it's omacom/omarchy #10598: the installer skipped NVRAM registration. From Fedora run `~/code/omarchy-migration/scripts/03-fix-omarchy-boot-entry.sh`. It finds Limine on whichever ESP the installer used (#7867: it may create its own instead of reusing Fedora's), registers it, and puts it first.
6. Fedora in the Limine menu: `FIND_BOOTLOADERS=yes` should auto-detect it, and `limine-scan` is the manual way. But `omarchy-refresh-limine` **deletes non-Omarchy entries** (#7867, confirmed on 4.0.4), so Phase 4 installs `limine-fedora-entry.path`, which re-adds Fedora every time `limine.conf` changes. The Surface boot menu (power on while holding Vol-Down → USB/boot options) always reaches Fedora too.
7. **If the ISO dies with `grub_memalign: out of memory` → `unable to mount root fs`**: that's omarchy-iso #128. The ISO's 241 MiB initramfs is too big for some firmware's GRUB, and Ventoy also chains through GRUB. Try Ventoy's GRUB2 mode (Ctrl+R in its menu); if that fails, write the ISO with `dd` to a dedicated stick.

---

## Phase 4: Surface kernel and hardware (`scripts/10-omarchy-surface.sh`)

- Adds the **linux-surface** Arch repo with its signing key **checked against the fingerprint** `87DE FA4A B94A 99A4 C8C3 1125 56C4 64BA AC42 1453` (verified 2026-10-17). The repo is added through Omarchy's `pre-refresh-pacman` hook, because `omarchy refresh pacman` rewrites `pacman.conf`.
- Installs `linux-surface linux-surface-headers iptsd libwacom-surface` (Fedora now runs the same kernel series: kernel-surface 6.19.8, iptsd 3.1.0).
- **No stock-kernel fallback.** Without the Surface Aggregator drivers the Laptop 4's keyboard and touchpad are dead, so that entry is useless. After you reboot into linux-surface, `./10-omarchy-surface.sh --finalize` checks that you really are on `-surface` and that `surface_hid` + `surface_aggregator` are loaded, takes a snapshot, then removes `linux`/`linux-omarchy` + headers with Omarchy's own `omarchy-pkg-drop` and rebuilds Limine. That's the same pattern Omarchy uses for its N1x laptops.
- Makes sure the Surface drivers are in the initramfs, so the built-in keyboard can type the disk password.
- Installs the fixed libinput quirks, your sysctl tweaks (BBR, fq_codel, inotify, btrfs writeback), and the fixed RAPL unit.
- **Boots linux-surface first.** Omarchy's default `BOOT_ORDER` puts `linux-omarchy` first, so between stage 1 and `--finalize` Limine would default to the wrong kernel. `/etc/limine-entry-tool.d/zz-surface-boot-order.conf` overrides it (the last file read wins, the same trick Omarchy uses for N1x).
- **Initramfs modules are appended (`MODULES+=`) in a `zz-` drop-in.** Omarchy's own `surface_device_modules.conf` uses `MODULES=` and wipes earlier entries (omacom/omarchy #7111).
- Rebuilds with `limine-mkinitcpio` (Omarchy builds UKIs), not `limine-update`.
- Installs the Surface fixes from `configs/surface-fixes/` (see **Known issues** below).
- ~~`mem_sleep_default=deep`~~ dropped: the Laptop 4 only supports `s2idle` (`/sys/power/mem_sleep`), so that Fedora cmdline option never did anything.

What needs the surface kernel on a Laptop 4: the touchscreen (IPTS → iptsd), the battery and thermal sensors through the Surface Aggregator, and smoother keyboard/touchpad. The camera is plain USB UVC and would work on the stock kernel too.

---

## Known issues & edge cases (from other Surface Laptop 4 / Omarchy users)

Collected 2026-10-17 from the linux-surface and Omarchy trackers. ✅ = fixed in this kit, ⚠ = watch for it.

| | Issue | Source | What we do |
|---|---|---|---|
| ✅ | **False 0% battery**: SAM times out reading BAT1 (`-110`), UPower sticks at 0 Wh and can fire its critical action (hibernate/power-off). Same model and same 6.19.8 kernel as yours | [linux-surface #2303](https://github.com/linux-surface/linux-surface/issues/2303) (filed today) | `surface-battery-watchdog` restarts upower on each timeout. **Running on Fedora now**; installed on Omarchy by Phase 4 |
| ⚠ | **Charging stops completely** (ADP1 offline, discharging while plugged in), same i7-1185G7. Reported cause: Surface Smart Charging. This morning's incident matched it (no `-110` in the logs) | [linux-surface #2070](https://github.com/linux-surface/linux-surface/issues/2070) | Full power cycle: shut down, unplug, hold power 15 s, replug. Check the Surface UEFI (Vol-Up + Power) for a battery-limit toggle. Firmware is **24.101.143 (Apr 2024)** and Surface firmware only updates from Windows (fwupd: "No updates available") |
| ✅ | Touchscreen (sometimes keyboard) dead after sleep | [linux-surface #1131](https://github.com/linux-surface/linux-surface/issues/1131) | `iptsd-resume.service` restarts iptsd after every resume (installed on Fedora). If the keyboard dies too, only a reboot helps |
| ✅ | Initramfs modules overwritten (`MODULES=` vs `+=`) | [omarchy #7111](https://github.com/omacom/omarchy/issues/7111) | our drop-in appends |
| ✅ | Stock kernel boots by default after adding linux-surface | Omarchy `BOOT_ORDER` (source) | `zz-surface-boot-order.conf` + `--finalize` removes the stock kernel |
| ✅ | Free-space install boots straight to the other OS (no NVRAM entry) | [omarchy #10598](https://github.com/omacom/omarchy/issues/10598) | `scripts/03-fix-omarchy-boot-entry.sh` (run from Fedora) |
| ✅ | Other OS's Limine entry wiped by `omarchy-refresh-limine`; installer makes a second ESP | [omarchy #7867](https://github.com/omacom/omarchy/issues/7867) | `limine-fedora-entry.path` self-heals |
| ⚠ | Installer ISO: GRUB out of memory on the 241 MiB initramfs | [omarchy-iso #128](https://github.com/omacom/omarchy-iso/issues/128) | Phase 3 step 7 |
| ✅ | TLP's sleep hook kept running after the service was disabled (fights ppd on every resume) | found locally | `TLP_ENABLE=0` in `/etc/tlp.conf` (Fedora). Omarchy doesn't ship TLP |
| ⚠ | Fans barely spin in the **low-power** profile → throttling to 200 MHz | [linux-surface #561](https://github.com/linux-surface/linux-surface/issues/561) | Omarchy defaults to performance on AC and balanced on battery; avoid power-saver for heavy work. linux-surface's thermald configs cover the SL4 **AMD** only, so keep thermald adaptive |
| ⚠ | Bluetooth (AX201) broke on one surface kernel series | [linux-surface #1603](https://github.com/linux-surface/linux-surface/issues/1603) | Omarchy keeps one kernel: roll back with a Limine snapshot or `sudo pacman -U /var/cache/pacman/pkg/linux-surface-<old>.pkg.tar.zst`. Fedora keeps 2 surface kernels |
| ⚠ | Intel Iris Xe panel flicker (PSR) | [Arch forums](https://bbs.archlinux.org/viewtopic.php?id=283520) | only if you see it: `echo 'KERNEL_CMDLINE[default]+=" i915.enable_psr=0"' \| sudo tee /etc/limine-entry-tool.d/60-psr.conf && sudo limine-mkinitcpio` (costs some battery) |
| ⚠ | Omarchy's docs say to turn off Secure Boot **"and/or TPM"** | Omarchy manual | Turn off **Secure Boot only**; keep TPM on (needed for Phase 7c). Only touch TPM if the installer refuses |
| ℹ | A stale "Windows Boot Manager" NVRAM entry points at a partition that no longer exists | `efibootmgr` | harmless; remove with `sudo efibootmgr -b 0005 -B` if it ever shows up in the menu |

## Phase 5: desktop (`scripts/30-desktop.sh`)

### Input: every setting ported (`configs/hypr/input.lua`)

| Setting | Fedora (GNOME / quirks) | Omarchy |
|---|---|---|
| Palm rejection | pressure 80, size 70, *never loaded* | same values, now actually loaded |
| **Thumb rejection** | not set | pressure 60, size 55 (tune with `libinput measure touchpad-pressure`) |
| Touchpad speed | 0.80 adaptive | `sensitivity 0.8` per-device |
| Scroll speed | wanted 0.5 (never applied) | `scroll_factor = 0.5`, ×1.5 in terminals |
| Natural scroll · tap-to-click · tap-drag | on · on · on | same |
| Right-click | two-finger (`click-method fingers`) | `clickfinger_behavior = true` |
| Disable while typing | on | on |
| 3-finger gestures | workspace / fullscreen | same |
| Mouse | flat, speed 1.0 | `accel_profile flat` |
| Keyboard repeat | 500 ms / 30 ms | `repeat_delay 500`, `repeat_rate 33` |
| Caps Lock | `caps:escape` | `caps:escape`, compose moved to Right Alt |
| Display | 2256×1504 @ 60, 1.33 | `scale 1.333333` (divides the panel cleanly → 1692×1128 logical) |

Two lines are marked `VERIFY`: the per-device block (`hl.device`) and the monitor syntax. Hyprland's Lua API is new, so check them against `hyprctl configerrors` on first boot.

### Shell: Omarchy default, Noctalia one command away

- **Omarchy shell** (Quickshell: bar, menu, notifications, OSD, lock) stays the default. It's what Omarchy themes and updates.
- **Noctalia v5** (`pacman -S noctalia`, in Arch `[extra]`) is the alternate. Note that v5 is a rewrite and **no longer Quickshell-based**; v4 is unmaintained.
- **`shell-switch noctalia` / `shell-switch omarchy`** swaps live without logging out. How it works: Omarchy forces its own `bin/` to the front of `PATH`, so `configs/hypr/shell-mode.lua` re-prepends a shim dir *after* Omarchy's defaults. The shim's `omarchy-launch-shell` starts whichever shell `~/.config/shell-mode` names, and in Noctalia mode the Lua file rebinds Super+Space, Super+S, Super+comma, Super+Ctrl+L and the media/brightness keys to `noctalia msg …`.

### Theme: Catppuccin (Mocha)

Picked because it's the one palette **all** your layers share natively: an Omarchy built-in theme (desktop, terminal, btop, Chromium, shell, *and* the boot-unlock screen), a Noctalia colour scheme, an SDDM astronaut variant, plus Ghostty, VS Code, Obsidian and GTK. So switching shells doesn't change the look. Runners-up: **Tokyo Night** (Omarchy's flagship) and **Ethereal** (most distinctive). `Super+Ctrl+Shift+Space` cycles all 24 themes to compare live.

### One theme switch → whole desktop, both shells, no logout

Omarchy's theme switch already re-themes Hyprland, the terminal, btop, nvim, Chromium, GTK, the shell and the lock screen live. Three additions cover the rest:

| Layer | Tool | Live? |
|---|---|---|
| **Noctalia** (when it's the active shell) | `configs/omarchy-hooks/theme-set.d/50-noctalia-palette` (written for you). It converts the active Omarchy `colors.toml` into a Noctalia v5 custom palette and sets `[theme] source = "custom"`. Tested against all 24 Omarchy themes, light ones included | yes |
| Discord | [omacord](https://github.com/xPsycho999/omacord) via **Vesktop** (Vencord built in) | yes, no restart |
| Spotify (Spicetify), Zen/Firefox, more | [theme-hook-plugin-manager](https://github.com/OldJobobo/theme-hook-plugin-manager) | mostly; Firefox-family needs one about:config flag |
| VS Code / Cursor | [Omarchy-IDE-Theme-Sync](https://github.com/Keyrxng/Omarchy-IDE-Theme-Sync) | yes |
| Obsidian | built-in Omarchy theme: select it once under *Appearance > Themes* | yes after that |

Rule: **Omarchy owns app theming**, and Noctalia only receives the palette (keep Noctalia's `builtin_ids = []`). Otherwise two tools fight over the same config files.

### Login screen

`sddm-astronaut-theme` (Qt6, animated) replaces Omarchy's SDDM look, set to a Catppuccin variant. You can preview it with `sddm-greeter-qt6 --test-mode`. Revert with one file delete.

---

## Phase 6: port your stack

| Thing | Fedora | Omarchy plan |
|---|---|---|
| Shell | zsh + oh-my-zsh + starship + atuin | Omarchy defaults to **bash**. `pacman -S zsh` → `chsh -s /bin/zsh` → restore `~/.zshrc`. Fix the `dnf` aliases (`update`) → `omarchy update` |
| Terminal | Ghostty + galaxy shader | `pacman -S ghostty` → *Setup > Defaults > Terminal*. Config ports as-is |
| Browser | Chrome flatpak (default) | Flatpak again, or `omarchy-pkg-aur-add google-chrome` |
| Flatpaks | 42 apps | `30-desktop.sh` reinstalls all except GNOME core apps (list in `inventory/flatpaks.txt`) |
| CLI tools | eza bat rg fd zoxide atuin starship fzf direnv btm dust procs navi tldr thefuck fastfetch | All in Arch `[extra]`. Omarchy already ships several |
| Bun / npm-global | omp, kilo, skillshare, … | Reinstall: `bun add -g @oh-my-pi/pi-coding-agent`, `npm i -g @kilocode/cli`, skillshare binary. Copy `~/.omp/agent/config.yml`, `~/.config/kilo/kilo.jsonc`, `~/.config/skillshare/` |
| Claude Code | `~/.claude/` | Copy whole dir (settings, skills, agents, memory) |
| Containers | podman: arr-suite (sonarr/radarr/lidarr/prowlarr), ai-stack | `pacman -S podman podman-compose` → copy `~/containers/` → re-enable user units |
| Docker | docker.service | Omarchy ships Docker with **ufw-docker** firewalling; check your ports |
| Ollama | llama3 (4.7 GB) | `pacman -S ollama` → `ollama pull llama3` (re-download beats copying) |
| User services | ai-stack, arr-suite, hermes-gateway, openclaw-gateway, voice-scribe, wallpaper-changer | Copy from `inventory/systemd-user/`. **wallpaper-changer.sh needs a rewrite**: it calls gsettings (GNOME). Use `omarchy` background commands or `noctalia msg` instead |
| Power | TLP + tuned + ppd (conflicting) | ppd only (Omarchy default) + thermald + fixed RAPL unit |
| Old Hyprland/niri/DMS configs | `~/.config/hypr` (hyprlang), DankMaterialShell, niri | Don't copy `hyprland.conf`: Omarchy 4 is **Lua**. Your 54 old keybinds are in `inventory/hypr/hyprland.conf` to translate into `~/.config/hypr/bindings.lua` (`o.bind`/`o.rebind`). DMS and niri are dropped |
| Firewall | firewalld | ufw (default deny in, LocalSend allowed). SSH stays off until *Setup > Security > SSHD* |
| Snapshots | none | Snapper + Limine: every Omarchy update is bootable-rollbackable (root only, not /home) |

---

## Phase 7: face login

**Hardware verified 2026-10-17:** `/dev/video2` (`Surface Camera Front: Surface I`) is greyscale-only, 480×480, with a strobing emitter and a clean lit-frame image.

### 7a. Use a marketplace plugin for sudo, polkit and the lock screen (recommended)

Omarchy 4's plugin marketplace now has about 8 face-unlock plugins. Best fits, in order:

1. **[pb3975/omarchy-face-auth](https://github.com/pb3975/omarchy-face-auth)**: the most careful one. It builds a **hash-pinned howdy-next 3.4.0** from official-repo dependencies only (no AUR scripts run), checks the face-model hashes, and auto-detects a **greyscale-only** node (your `video2` qualifies; RGB webcams are refused, so a printed photo can't unlock it). It writes PAM *only after* enrollment and a test both pass, gates on lid-closed, and ships a lock-screen plugin that runs 3-attempt bursts. Removal is clean: `omarchy remove security face`.
   ```bash
   omarchy plugin add https://github.com/pb3975/omarchy-face-auth
   bash ~/.config/omarchy/plugins/io.github.pb3975.face-auth/scripts/install.sh
   omarchy setup security face        # enroll with AND without glasses
   omarchy plugin enable io.github.pb3975.face-auth
   ```
2. [therealasclepius/omarchy-face-unlock](https://github.com/therealasclepius/omarchy-face-unlock): uses **Facelock** (Rust) and scans *automatically* when the lock screen appears. Its setup currently checks for Omarchy **4.0.2/4.0.3** fingerprints and stops on 4.0.4, so wait for an update.
3. [Kalinewb/omarchy-face](https://github.com/Kalinewb/omarchy-face): a guided setup panel and up to 3 "appearances" per person (glasses on and off). Lock screen is off by default.

### 7b. Login screen (SDDM): `scripts/20-face-login.sh` step 5 only

The plugins deliberately don't touch the login screen. If you want face at SDDM too, run only step 5 of the script (turn off autologin, add face to `/etc/pam.d/sddm`). Steps 1–4 duplicate what the plugin does; **skip them if you used the plugin.**

The script's original steps, kept as a manual fallback (each step asks first, every PAM file gets a `.pre-howdy` backup):
1. Installs `howdy-git` (Howdy 3.x) from the AUR. Read the PKGBUILD.
2. Points it at the IR node with `dark_threshold 90` (a Surface Laptop 5 needed that) and a 6 s timeout.
3. Enrolls your face 3× (normal light, dim light, glasses).
4. Adds face to **sudo**, **polkit** admin prompts and the **Omarchy lock screen** (`/etc/pam.d/omarchy-lock-password`). It's gated the way Omarchy gates fingerprints: **lid closed → straight to password.**
5. Turns off SDDM autologin and adds face to the **login screen**.

**Honest limits**
- **The disk password at boot can't be your face.** LUKS unlocks before any camera code runs. So "Windows Hello at power-on" needs Phase 7b. Without it, you type the disk password at boot, and from then on you're face-only for lock, sudo and admin prompts. Omarchy's default autologin after unlock is a perfectly good setup.
- **SDDM needs one Enter press** on the empty password field to start the scan. No Linux greeter starts scanning by itself yet.
- **Howdy is weaker than Windows Hello.** IR helps against photo spoofs, but it's a convenience login, not a security boundary. Password always works as fallback.
- If the IR emitter doesn't light up: `linux-enable-ir-emitter` (AUR).
- Reference implementation: [omarchy-surface-restore](https://github.com/menmer0859/omarchy-surface-restore). It was verified on a Laptop 5 + Omarchy 4.0.4 and ships a proper face lock-screen *plugin*. Worth reading before step 4, and possibly better than patching the password PAM stack.

### 7c (optional, highest risk): TPM auto-unlock → true walk-up login

Flow: power on → TPM unlocks the disk silently → SDDM → look at the camera → desktop. That's the Windows Hello experience.

Cost: anyone holding the laptop gets as far as the login screen, which is roughly where Windows-with-BitLocker-TPM leaves you too. And with Secure Boot **off** (Omarchy requires that), PCR 7 binding is weaker than on Windows.

Mechanics: Omarchy's initramfs uses the classic `encrypt` hook, and TPM unlock needs the systemd hooks. So you'd add a *later-sorting* drop-in `/etc/mkinitcpio.conf.d/zz-tpm.conf` that swaps `udev→systemd`, `encrypt→sd-encrypt`, `keymap consolefont→sd-vconsole`, then run `systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 <luks-partition>` and rebuild. **Take an `omarchy-snapshot create` first, keep the password keyslot, and keep the Fedora entry until this has survived several reboots and an Omarchy update.** It isn't scripted on purpose: do it by hand, with the snapshot.

---

## Phase 8: Fedora as the permanent backup OS

- Fedora keeps its 120 GB and its own `/boot`. It boots from the Limine menu (→ Fedora GRUB → surface kernel only).
- Boot it about monthly and run `sudo dnf upgrade --refresh`, so it's current when you actually need it. The stock-kernel exclusion stays in `/etc/dnf/dnf.conf`.
- Share data between the two over `/home`? Don't mount each other's home. Keep the shared stuff in git, Syncthing or a dedicated btrfs subvolume instead (two desktops writing one `~/.config` = pain).

---

## Dotfiles: making the whole setup reproducible

What's recommended for Omarchy 4 right now is **Omarchy as the base + a chezmoi overlay of only the files you change**. Never edit `/usr/share/omarchy`; put overrides in `~/.config`, and use a `post-update` hook to re-apply after every Omarchy update.

- Good references, all current and Omarchy-4/Lua-aware: [joaodrp/omarchy](https://github.com/joaodrp/omarchy) (bootstrap = `omarchy pkg add chezmoi && chezmoi init --apply <repo>`, plus a post-update hook that re-runs apply), [coldter/omarchy-dotfiles](https://github.com/coldter/omarchy-dotfiles) (per-machine profiles and a drift-check hook), [scottwater/omarchy-dotfiles](https://github.com/scottwater/omarchy-dotfiles) (tracks only selected files).
- Plan: turn `~/code/dionysus/dotfiles` into a chezmoi source holding **this folder's** `configs/hypr/*.lua`, the shell-switch shim, the Noctalia hook, zsh, Ghostty and starship. After that, a fresh Omarchy install is: ISO → `10-omarchy-surface.sh` → `chezmoi init --apply`.
- Not recommended: full rice repos (HyDE, JaKooLit, ML4W, End-4, Caelestia). They replace Omarchy's configs wholesale and fight its updates.

## Cutting-edge extras worth installing (Rust wave, Oct 2026)

| Tool | ★ | Why |
|---|---|---|
| [rtk](https://github.com/rtk-ai/rtk) | 83.7k | CLI proxy that cuts LLM token use 60–90% on common dev commands. Pairs with Claude Code, omp and kilo |
| [abtop](https://github.com/graykode/abtop) | 3.8k | htop for AI coding agents (Claude Code / Codex sessions) |
| [pi_agent_rust](https://github.com/Dicklesworthstone/pi_agent_rust) | 1.9k | Rust port of Pi (the agent omp forks from) |
| [goose](https://github.com/aaif-goose/goose) · [codex](https://github.com/openai/codex) · [grok-build](https://github.com/xai-org/grok-build) | 55k · 130k · 27k | Rust agent harnesses |
| [zed](https://github.com/zed-industries/zed) · [jj](https://github.com/jj-vcs/jj) · [yazi](https://github.com/sxyazi/yazi) | | editor, VCS and file manager (yazi has an Omarchy theme) |
| [facelock](https://github.com/tyvsmith/facelock) | new | Rust face-auth daemon (behind option 2 in Phase 7a) |
| **storytold "*craft" suite** | 65k+ | The big trend right now: AI-assisted, clean-room, pure-Rust rewrites of whole app categories. [PhotoCraft](https://github.com/storytold/photocraft) (Photoshop, PSD support), PdfCraft, FilmCraft, WordCraft, LightCraft, VectorCraft. **Early alpha**: try, don't depend |
| [spotifast](https://github.com/crmne/spotifast) | 8.4k | native Rust Spotify client (egui, MPRIS) |

## Omarchy plugins worth a look (marketplace: `omacom/omarchy-plugin-marketplace`)

- ~~tcballard/omarchy-surfacecheck~~: NOT a Surface hardware tool. Its README says it is a visual-inspection workflow for Omarchy UI surfaces (screenshots). Removed 2026-10-18 after omp's sweep flagged it and the README confirmed it.
- [varlet99/omarchy-tablet](https://github.com/varlet99/omarchy-tablet): touch-friendly tablet mode, on-screen keyboard (you have a touchscreen)
- [OldJobobo/lacuna-shell](https://github.com/OldJobobo/lacuna-shell): a shell extension suite (★29)
- Spotify, Discord and Obsidian integrations: dozens; search the marketplace's `registry.json`

---

## Rollback at every stage

- **Phase 2–3:** Fedora untouched except for size. Pick it in Limine (or in the Surface UEFI boot order).
- **Phase 4:** no stock kernel by design. If linux-surface ever fails to boot: Limine → a bootable snapshot, or the **Fedora entry (permanent)**, or the Omarchy USB + `arch-chroot`. Keep the USB stick.
- **Any system change:** Limine → bootable snapshot → `omarchy-snapshot restore`.
- **Phase 7:** `sudo mv /etc/pam.d/<svc>.pre-howdy /etc/pam.d/<svc>`; autologin files are renamed `*.disabled-by-face-login`, not deleted.
- **Configs:** *Update > Config* in the Omarchy menu, or `omarchy reinstall configs`.

---

## Folder map

```
README.md                  this plan
inventory/                 snapshot of Fedora (packages, gsettings, /etc tweaks, user units, old hypr conf, hardware, dirty repos)
configs/
  etc/libinput/            fixed palm + thumb rejection quirks
  etc/sysctl.d/            ported sysctl tweaks
  etc/systemd/system/      fixed RAPL power-limit unit
  hypr/input.lua           touchpad / mouse / keyboard
  hypr/monitors.lua        2256x1504 @ 1.333333
  hypr/shell-mode.lua      Noctalia keybinds when that shell is active
  shell-switch/bin/        omarchy-launch-shell shim + shell-switch command
  omarchy-hooks/theme-set.d/50-noctalia-palette   Omarchy theme → Noctalia palette, live
  surface-fixes/           battery watchdog, iptsd-resume, limine-fedora-entry (+ units)
scripts/
  01-export-inventory.sh   Fedora, read-only
  03-fix-omarchy-boot-entry.sh  Fedora: register Limine in NVRAM if the installer didn't (#10598)
  02-preflight-fedora.sh   Fedora, read-only (+ one IR test frame)
  10-omarchy-surface.sh    Omarchy: linux-surface, iptsd, quirks, sysctl, RAPL
  20-face-login.sh         Omarchy: Howdy + PAM + SDDM
  30-desktop.sh            Omarchy: input, Noctalia, theme, SDDM theme, flatpaks
```

## Open items to verify on first boot

- [ ] `hl.device({...})` per-device syntax and `hl.monitor` syntax in Hyprland's Lua API (`hyprctl configerrors`)
- [ ] Built-in keyboard works at the LUKS prompt (else: USB keyboard, then check `/etc/mkinitcpio.conf.d/surface_device_modules.conf`)
- [ ] After stage 1 the Limine **default** is linux-surface (BOOT_ORDER drop-in); after `--finalize` only linux-surface + snapshots + Fedora remain
- [ ] `limine-fedora-entry` syntax (`protocol: efi`, `path: guid(...)`) boots Fedora; check against `man limine`
- [ ] `systemctl is-active surface-battery-watchdog` and `systemctl is-enabled iptsd-resume limine-fedora-entry.path`
- [ ] `noctalia msg --help`: confirm the `lock` verb used in `shell-mode.lua`
- [ ] Noctalia handles idle/lock when the Omarchy shell is off (Omarchy's idle lives in its shell)
- [x] IR emitter lights: verified on Fedora 2026-10-17 (alternate-frame strobe)
- [ ] `noctalia msg --help`: confirm a palette/theme reload verb (the hook calls `theme-reload`; Noctalia also hot-reloads config)
- [ ] Noctalia config path is `~/.config/noctalia/config.toml` (the hook assumes it)

## Sources

- Omarchy manual (quattro branch): [getting started](https://github.com/basecamp/omarchy/blob/quattro/manual/02-getting-started.md), [input](https://github.com/basecamp/omarchy/blob/quattro/manual/34-keyboard-mouse-trackpad.md), [dotfiles](https://github.com/basecamp/omarchy/blob/quattro/manual/31-dotfiles.md), [themes](https://github.com/basecamp/omarchy/blob/quattro/manual/06-themes.md), [snapshots](https://github.com/basecamp/omarchy/blob/quattro/manual/47-system-snapshots.md), [dual boot](https://github.com/basecamp/omarchy/blob/quattro/manual/50-dual-boot-install.md), [security](https://github.com/basecamp/omarchy/blob/quattro/manual/48-security.md); source read for SDDM, initramfs hooks, Surface hardware scripts, lock-screen PAM
- [Noctalia](https://github.com/noctalia-dev/noctalia) · [install](https://docs.noctalia.dev/noctalia/getting-started/installation/) · [Hyprland setup](https://docs.noctalia.dev/noctalia/compositor-settings/hyprland/)
- [linux-surface](https://github.com/linux-surface/linux-surface) (Arch repo + signing key)
- [Howdy](https://github.com/boltgolt/howdy) · [ArchWiki: Howdy](https://wiki.archlinux.org/title/Howdy) · [omarchy-surface-restore](https://github.com/menmer0859/omarchy-surface-restore)
- Face plugins: [pb3975/omarchy-face-auth](https://github.com/pb3975/omarchy-face-auth) · [therealasclepius/omarchy-face-unlock](https://github.com/therealasclepius/omarchy-face-unlock) · [Kalinewb/omarchy-face](https://github.com/Kalinewb/omarchy-face) · [Omarchy plugin marketplace](https://github.com/omacom/omarchy-plugin-marketplace)
- Noctalia theming: [palette](https://docs.noctalia.dev/noctalia/theming/palette/) · [app theming](https://docs.noctalia.dev/noctalia/theming/app-theming/) · [noctalia-theme-sync](https://github.com/dr6m6/noctalia-theme-sync)
- Omarchy SDDM/autologin context: [discussion #2479](https://github.com/omacom/omarchy/discussions/2479), [issue #7949](https://github.com/omacom/omarchy/issues/7949)
