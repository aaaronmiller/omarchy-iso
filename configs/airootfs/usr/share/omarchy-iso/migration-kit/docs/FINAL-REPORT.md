> Snapshot baked into the ISO at build time. Latest: ~/code/omarchy-iso/research/ (FINAL-REPORT.md, LEDGER.md).

# Final report: Surface Laptop 4, Fedora 43 to Omarchy 4 (2026-10-18)

Tags: [CMD] verified by a command run this project, [FILE] read in a file, [WEB] web source in research/, [UNVERIFIED] not checked on the target. Nothing here has been tested on the laptop itself.

## 1. What exists

| Item | Where | Status |
|---|---|---|
| Custom Omarchy ISO, build 1 of the 2026-10-18 flow (linux-surface, installer fixes, migration kit baked in) | `~/code/omarchy-iso/builds/1/src/release/omarchy-2026.10.18-x86_64-quattro.iso`, sha256 `40d434ac...1f40` | `tools/status.sh 1` = DONE (exit 0, fresh, checksum recorded) [CMD]. Kit inside the image is byte-identical to the source tree (106 files, tree hash `0dad9c1e`) [CMD: unsquashfs]. Boots: [UNVERIFIED] |
| Same ISO on the Ventoy stick | `Ventoy/omarchy-2026.10.18-x86_64-quattro.iso` | checksum MATCH [CMD, finish-stick.sh log]. Previous ISO (`...10.17`, sha `237fe033...`) removed from the stick after its identical copy at `src/release/` was confirmed |
| Fedora | Kept, shrunk to 120 GiB online | Done [CMD] |
| Migration kit | `~/code/omarchy-migration/`; tarball, `turnkey.sh` and `00-NEXT-AGENT-PROMPT.md` on the stick | Checksums MATCH [CMD]. Scripts pass `bash -n` and shellcheck [CMD] |
| Installer phase `stage_migration_kit` | `src/configs/airootfs/usr/share/omarchy-iso/orchestrator/` | 5 unit tests pass [CMD]; real install run: [UNVERIFIED] |
| Dotfiles overlay (stow) | `dotfiles/` | Tested on a throwaway home only [CMD] |
| Theme and shell switching | `dotfiles/APPEARANCE.md`, `configs/shell-switch`, Noctalia palette hook | Hook tested in a throwaway home [CMD]; live swap on Hyprland [UNVERIFIED] |
| Agent helpers | `agent-prompts/` (7), `scripts/agent-assist.sh` | Launcher guard and dry run tested [CMD]; the agents themselves not run |
| Extras installer | `scripts/50-extras.sh` | `--list` and bad-name path tested [CMD]; installs not run |

## 2. Post-install flow (turnkey)

Install the ISO on the Surface. On Surface hardware (DMI check) the installer phase "Staging migration kit" copies the kit to `/usr/share/omarchy-migration-kit`, writes the machine-wide migration marker `/var/lib/omarchy/migrations/1789325478`, and adds `/etc/xdg/autostart/omarchy-migration-firstlogin.desktop`. First login: `firstlogin.sh` disarms itself, copies the kit to `~/code/omarchy-migration`, waits for pacman and network, and opens a terminal running `scripts/00-postinstall.sh --auto` (finalize, packages, dotfiles overlay, Noctalia hook, summary at `reports/postinstall-summary.md`). Tested with stubs: 7/7 first-login checks [CMD: tools/test-firstlogin.sh], 14/14 post-install checks [CMD: scripts/test-postinstall.sh].
- Omarchy itself ships XDG autostart entries (`limine-snapper-notify.desktop` in omarchy-settings 4.0.4) [CMD: package listing], so the mechanism fits; that it fires on this machine is [UNVERIFIED].
- Fallbacks: `scripts/turnkey.sh` from the stick, or `scripts/00-postinstall.sh` by hand. `--dry-run`, `--no-finalize`, `--include-optional`, `--agent`.
- Auto mode: yes to normal steps, no to optional and risky ones; the finalize safety checks (driver loaded, Surface boot image on disk, snapshot, `limine-mkinitcpio` must succeed) still run [FILE: 10-omarchy-surface.sh].
- Bug fixed on the way: `40-overlay.sh` asked about the official packages but never installed them [FILE]. Build fix: `run-build.sh` now passes `--no-boot-offer` (the first attempt exited 127 on a missing `gum`; that ISO is kept as `builds/1-exit127-boot-offer-gum`, not used).

## 3. Package decisions

Default: `packages/pacman-official.txt` (stow git-delta podman crun direnv zsh-autosuggestions ghostty worktrunk), `aur.txt` (lazysql-bin zsh-fast-syntax-highlighting). Opt-in via `50-extras.sh` (ledger D4): `extras-official.txt` (television yazi gitui jujutsu atuin helix ast-grep bottom), `extras-aur.txt` (rtk-bin abtop walker-bin codewhale). Dropped as duplicates because Omarchy 4.0.4 bundles them [CMD: ISO offline mirror listing, tools/audit-claims.sh]: zsh nss unzip wl-clipboard lazydocker herdr (and mise-bin, btop). Old lists backed up as `*.bak-2026-10-18`.
Correction: Noctalia v5 is `noctalia 5.3.0` in Arch `extra` [CMD, archlinux.org API], not AUR-only as an earlier draft said. Kit references already point to `extra`.

## 4. Risks

1. ISO boot untested; Ventoy did not start from the stick on the laptop, cause unknown, Secure Boot is off [CMD]. Try a direct port, or `dd` the ISO to a separate 8 GB+ stick (checklist: `patches/TEST-CHECKLIST.md`). A ~244 MB initramfs may hit GRUB out-of-memory (omarchy-iso #128) [WEB, UNVERIFIED here].
2. Qt 6.12 breaks plugins using a bare `Color.` [WEB]. UPDATED 2026-10-18 [CMD: gh api, pkgs.omarchy.org/stable omarchy.db, stable-mirror extra.db]: omarchy v4.0.5 was released 2026-10-18 02:50 UTC with the shell fix (#14553 and backport #15265 closed); the stable mirror now serves omarchy 4.0.5-1 AND qt6-declarative 6.12.0-1. The earlier statements "4.0.5 not cut" and "stable mirror on Qt 6.11.2" (omp R23, my report) are stale. #14597 (fix for cloned built-in plugins) is still open, so third-party plugins with a bare `Color.` still break; audit them first (`agent-assist.sh run audit-plugins`).
3. Omarchy migration 1789325478 demotes linux-surface; the kit and stage 1 create its marker [FILE]. Confirm the marker exists after install.
4. The unvetted omp Surface fixes stay disabled (`configs/surface-fixes/unvetted/`); several target USB models, not the Laptop 4.
5. Touchscreen scroll in Ghostty and wofi: unexplained, app-level [CMD: Chrome scrolls].

## 5. Needs the user

- Boot test of the new ISO (direct USB port, or `dd` it to a separate 8 GB+ stick; Secure Boot stays off; USB keyboard handy). Then log in once and type your password when the post-install terminal opens.
- Decisions made: stow (kept), face login yes with gaze (`agent-assist.sh run face-login --agent` after install), extras via `50-extras.sh`. Still open: two-finger right-click (needs a code review of the 10 KB root script; stays off), which extras to keep.
- Done this session: corrected `ai-root` installed and tested (cmp identical, `pkg-install git` ok, option injection rejected) [CMD].
- Housekeeping for you: rename `~/.secrets` and `~/.buttplug` back or not; clear the rofi core dumps and rofi autostart on Fedora; renew the OpenAI and OpenCode keys; the two diverged and nine dirty repos.

## 6. Not covered

The 250-search target was not met by count; Reddit stayed blocked to the search tool; Sonnet's own recovery manifest was never written (usage limit), recovered files were hash-compared instead. Detail: `CONSOLIDATED-REPORT.md`, `LEDGER.md`, `AUDIT.md`.

## 7. Claim audit (2026-10-18, `research/AUDIT-CLAIMS.txt`, `tools/audit-claims.sh`)
Checked live against archlinux.org, the AUR RPC, the ISO mirror and the signing-key file [CMD]: every package in the kit lists exists (Noctalia `extra 5.3.0`, worktrunk `extra 0.80.0`, gaze trio `0.3.10-1` all present, none orphaned); `opencv 5.0.0` satisfies gaze-bin's pin; the linux-surface signing fingerprint matches `87DEFA4A...1453`; the claim "Omarchy already ships herdr" is TRUE, which also exposed five more bundled duplicates (fixed above). Not re-checked: the content of the omp and Sonnet recovered reports beyond hash comparison, and Noctalia IPC verbs (`session lock`, `config-reload`) against Noctalia's source [UNVERIFIED].

## 8. Staleness found by the audit (2026-10-18)
- Omarchy 4.0.5 is out and the stable mirror moved to Qt 6.12.0 after the first rebuild of the ISO; the ISO was rebuilt again to ship 4.0.5 (build 2, see section 1 for its checksum). [CMD]
- Noctalia IPC verbs `session lock` and `config-reload` confirmed in Noctalia's own docs and `session_ipc.cpp`; `theme-reload` does not exist; `color-scheme-set` writes `settings.toml` (the reason the palette hook warns about a GUI `[theme]`). [CMD: raw.githubusercontent.com/noctalia-dev/noctalia]
- omarchy-iso upstream had only CI/test merges (#283 to #288) since our base `12a07ba`; no image-affecting change found. [CMD: gh api commits]
- Post-install bugs found by the end-to-end stub test and fixed: scripts not executable (silent skip), failures not reported, `find | grep -q` SIGPIPE under pipefail, boot-image check needed sudo (the ESP is root-only), Surface tweaks skipped when the ISO already installed the kernel, Qt-guard skip counted as done. [CMD: scripts/test-fullflow.sh, 48 checks]
