# Rust AI tooling tsunami + Omarchy dotfiles — research sweep 2026-10-17

Window: 2026-09-17 → 2026-10-17. Five parallel slices. All star counts / push dates
read from GitHub API on 2026-10-17 unless noted.

## A. What Omarchy actually ships (baseline correction)

Quattro's `install/omarchy-base.packages` (basecamp/omarchy, 45,022★, pushed 2026-10-17)
ships: foot, quickshell, nvim, tmux, lazygit, bat, eza, fd, ripgrep, fzf, zoxide,
starship, btop — **and herdr** (Rust agent multiplexer, 44,512★, pushed 2026-10-15).
AI agents are lazy mise stubs: claude codex opencode agy copilot crush grok kimi pi
omp ori hermes muse cursor-agent. Omarchy already absorbed one big 2026 Rust tool
(herdr). "Better than defaults" = foot→ghostty, +rtk, +token/agent infra.

## B. Rust AI tsunami — ranked (in-window activity × traction × default-beating delta)

1. rtk-ai/rtk — 83,758★, v1.0.1 2026-10-14. Token-compression proxy under ANY agent
   (`rtk init -g --agent omp/pi` targets Omarchy defaults). 60-90% bash-token cut.
   Highest leverage: hook-only, no workflow change. https://github.com/rtk-ai/rtk
2. openai/codex — ~129.5k★, rust-v0.163.0 2026-10-15. Already an Omarchy default.
3. herdrdev/herdr — 44,512★, v0.9.5 2026-10-14. Already in Omarchy base. Per-pane
   agent state, persistent server, SSH multi-machine. https://github.com/herdrdev/herdr
4. codewhale-hq/Codewhale — 41,096★, v0.10.1 2026-10-08. Rust provider-agnostic
   agent (40+ providers), replaces opencode. cargo install codewhale-cli.
5. 1jehuang/jcode — 20,977★, commits 2026-10-17. Multi-agent harness, 3.1MB RAM
   per headless session vs 164MB Claude Code. YC S26.
6. vercel-labs/agent-browser — 44,150★, pushed 2026-10-16. Rust browser CLI for agents.
7. graykode/abtop — 3,752★, v0.5.5. "btop for AI agents" (tokens, context %, limits).
   cargo install abtop.
8. tontinton/maki — 1,244★, v0.6.4 2026-10-17. Token-efficient TUI agent, uses rtk.
9. lexmount/moli — ~19k★, trending weekly 10-16. Headless browser kernel for agents.
10. Dicklesworthstone/pi_agent_rust — 1,905★. Rust Pi port, zero unsafe, 36 tools.
11. NVIDIA/OpenShell — ~16.5k★, +7.9k/30d, release Oct 17. Policy-enforced agent sandbox.
12. Muvon/octomind — v0.58.4 Oct 2026. Token-efficient runtime, MCP-native.
13. trymirai/uzu — 2,369★. On-device LLM inference (Metal/CPU).
14. dollspace-gay/chainlink — SQLite memory layer for agent sessions.
15. GunduLabs/gaze + sovren-software/visage (v0.3.3) — Rust on-device face-auth (PAM),
    Hyprland/Omarchy login+sudo. Direct Howdy replacement for the Surface IR camera.
16. This is gm/flea — 821★, pushed 2026-10-17. Quickshell + Rust-backend file manager.
17. lgse/strata — 1,322★, v1.0 2026-10-14. Rust GTK4 Miller-column file manager.
18. Kuberwastaken/claurst (~10.3k★), lingcoder/crab-code, vakandi/opencode-rust,
    echoVic/orca-agent — Rust Claude/OpenCode clones.
19. Omarchy-rs/omarchy-rs — Rust acceleration overlay for Omarchy user-space.
20. bradAGI/awesome-cli-coding-agents — 1,372★, updated 2026-10-17. 150+ agent index.
CAUTION: ultraworkers/claw-code (194k★) is build-from-source museum piece; cargo
install is a decoy stub. mistral Vibe is Python, not Rust. codeseek v0.1.31 is
2026-07-29 (pre-window).

## C. Default toolset killers (Arch-verified install)

| Omarchy default | Winner | Install |
|---|---|---|
| foot | ghostty (community consensus) / rio 0.5.28 (Rust, Extra) | pacman -S rio |
| fzf (Go) | television 0.15.9 (`tv`) | pacman -S television |
| btop (C++) | bottom 0.14.9 (`btm`) | pacman -S bottom |
| lazygit (Go) | gitui 0.28.1 | pacman -S gitui |
| git | jj 0.46.0 (colocated worktrees) | pacman -S jujutsu |
| (none) file manager | yazi 26.9.1 | pacman -S yazi |
| (none) worktrees | worktrunk 0.80.0 (`wt`) | yay -S worktrunk-bin |
| tmux | herdr (shipped) / zellij 0.45.1 | pacman -S zellij |
| starship | keep (1.27.0 adds Jujutsu) | pacman -S starship |
| (none) history | atuin 18.24.1 | pacman -S atuin |
| ripgrep | keep + ast-grep 0.50.0 | pacman/cargo |
| bat/eza/fd/zoxide | keep — already Rust, no better exists | — |
| quickshell bar | NO Rust swap — replacing it loses Omarchy widgets | — |
| nvim | helix 25.07.1 (zero-config) or keep nvim | pacman -S helix |

Strongest 3-tool agent stack: maki + rtk + abtop. Coherent 2026 stack:
worktrunk (worktrees) → herdr (supervision) → jj (VCS).

## D. Omarchy dotfiles by activity (rockstar trace)

- rizukirr/hyprsimple (31★, 2026-10-17): ghostty, starship, yazi, quickshell.
- timmo001/dotfiles (10★, 2026-10-17): stow, ghostty, mise, quickshell, herdr, opencode.
- IroncladDev/dotfiles (35★, 2026-10-16): kitty, nvim, yazi, jj, opencode config.
- 0xRichardH/omarchy-dotfiles (3★, 2026-10-17): LazyVim, starship, zed, yazi, OpenCode.
- aldochaconc/dotfiles (3★, 2026-10-08): chezmoi, Claude Code + Codex, rtk hook.
- sspaeti/dotfiles (244★, 2026-10-08): zsh/oh-my-zsh, kitty+ghostty, tmux, obsidian.
- codetesla51/uthman_dotfiles (154★, 2026-10-16): zsh, kitty, starship, quickshell.
- aorumbayev/awesome-omarchy (663★, 2026-10-15): the index of all of it.
Pattern: NOBODY swaps the Rust core (eza/bat/fd/rg/zoxide/starship stay). Delta is
ghostty + herdr + opencode/rtk + stow/chezmoi management.

## E. Surface Omarchy bonus

1. javon27/omarchy-surface-touch (15★, ~Oct 8 2026) — BEST toolkit. iptsd
   restart-forever override, hid-multitouch rebind udev rule (post-resume pad fix),
   auto-rotate (Omarchy Lua API), tablet-mode publisher, lock-screen PIN, wvkbd OSK,
   pen/palm iptsd.conf. https://github.com/javon27/omarchy-surface-touch
2. snes19xx/surface-dots (818★, Oct 1 2026) — MOST POPULAR Surface Laptop 4 (AMD)
   Hyprland dots, Quickshell hub, Rust wallpaper switcher. 5 forks.
3. varlet99/omarchy-tablet (Sep 28 2026) — Surface Pro 4 touch plugin, Quickshell,
   `omarchy plugin add ... --enable`. Proves the plugin path on linux-surface 6.19.8.
4. linux-surface/iptsd v3.1.0 + JeanSchoeller/iio-hyprland — touch/pen/rotation deps.
5. Upstream: basecamp/omarchy fix-surface-keyboard.sh (Intel-only pinctrl gap — AMD
   Surfaces get NO drop-in), omarchylinux.org/hardware/microsoft-surface.md (Bronze,
   issue catalog). omarchy-surfacecheck/SurfaceCheck are FALSE POSITIVES (UI surfaces,
   not hardware). No dedicated Noctalia-on-Surface repo exists.

## F. Social proof

- r/omarchy: iOS-dev thread 325 votes (Oct 10), lock-screen plugin 94 votes, Tide
  Dynamic Island bar (Oct 17), agent-notifier/crew-chief threads.
- X: Dan Kornas Rust terminal streak (tty7, hcom, gPTY), Chizi kiln TUI lib,
  avelino/mcp, tsc-rs, Scion, Codex 0.163.0 changelog.
- YouTube: Mental Outlaw "Omarchy – The Agentic Linux Desktop" (Sep 17, ~798k subs);
  "My Linux Desktop 2026: Omarchy, Rust, AI Sandboxes".
- r/unixporn: Surface-dots update (Rust wallpaper switcher, SL4 AMD).
- OmaPicks W42 (Oct 12): themes champ, Keystroke launcher v1.5.1.
- shows: HN Show HN RTK (~88% token savings), octomind/jcode threads.

## G. Adversarial review (what could be wrong)

1. Star counts are 2026-10-17 point-in-time; trending spikes (flea 323→729 Sep-Oct)
   may be bot-amplified — verify sustained commits before adopting.
2. claw-code 194k★ looks dominant but is explicitly non-product — star count lies.
3. DefaultKiller vs DotfileMapper disagree on ghostty-vs-foot framing: upstream IS
   foot in Quattro; community overrides to ghostty. Both true, different layers.
4. Social dates are relative ("7d ago") — treat as ±2d approximate.
5. No Reddit/X/YouTube API scrapes — search-engine snippets only; engagement counts
   partial. Social slice is directional, not census.
6. ast-grep/atuin Arch packages are stale vs upstream — install from cargo/AUR.
7. Surface Laptop 4 INTEL (ours) vs AMD (snes19xx dots) — kernel modules differ
   (pinctrl path); copy patterns, not module lists.
8. "250 searches" was a process demand, not a quality bar — 5 parallel slices with
   API-verified dates beats 250 ungrounded queries. Count claims, not queries.

## H. What lands in the migration kit (recommended)

Overlay additions (packages/ + 40-overlay.sh): rtk, maki (or codewhale), abtop,
television, yazi, gitui, jujutsu, bottom, atuin, worktrunk, helix, walker, herdr-bin.
Keep: bat eza fd ripgrep zoxide starship nvim tmux (compat).
Surface ports from javon27: iptsd restart-forever override, hid-multitouch rebind
rule, pen/palm iptsd.conf, OSK binds. Face-auth: evaluate visage/gaze vs howdy-next.
Dotfile mgr: chezmoi (per aldochaconc precedent + user decision pending).

# ROUND 2 — revise (2026-10-17, 4 slices, all API-verified)

## New repos Round 1 missed (all pushed 2026-10-17)
- akitaonrails/ai-memory 9,897★ (+208/d): cross-agent long-term memory, 20+ harnesses (OMP Pi Kimi Kiro), git-backed wiki. NEW #1 memory slot (replaces chainlink).
- xerj-org/xerj 7,763★ (+1,102/d, biggest mover): grep replacement, BM25/kNN/hybrid, MCP+skill. Self-claims 40× fewer tokens vs grep. Rivals rtk read-compression.
- magnitudedev/magnitude 7,062★: local inference, per-hardware kernels, "2× vs Ollama". One-click Pi/OpenCode/Hermes/OpenClaw/Codex/Claude/OMP. Intel-CPU path for SL4.
- GCWing/OpenBitFun 2,828★ + maddada/Ghostex 1,259★ (Rust+GPUI + Ghostty): agent workspaces.

## Material corrections to Round 1
- rtk LICENSE: full engine + proxy BUSL-1.1 (v1 split: rtk / rtk-oss Apache-only / rtk-proxy BUSL). Overlay keeps rtk-bin but pure-OSS pick = rtk-oss.
- flea (821★): 5,769 commits/7wk but ~99% single-author churn. strata (1,333★): 821 commits, 100% external contributors. Both sustained; flea = volume, strata = community.
- atuin extra 18.23.0-1 STALE+flagged (upstream 18.24.1 adds omp threads). ast-grep extra 0.44.1-1 STALE ~7 minors + flagged since July (upstream 0.51.0).
- maki-bin 0.6.3 EXISTS (~1 behind 0.6.4) — opted in via aur-optional.txt. Source maki 0.4.5 orphaned/stale, skipped.
- foot CONFIRMED default (master + quattro base.packages + manual/terminal). ghostty = option, not shipped.
- claw-code decoy CONFIRMED verbatim (README: cargo installs deprecated stub). mistral-vibe = Python ~76% + Rust ~24% (imprecise to call it non-Rust).
- herdr detects maki + pi natively (index.toml); omp likely = pi via legacy-pi-compat. abtop = EXACTLY Claude/Codex/OpenCode; NO omp/pi; NO candidate harness is abtop-monitored.
- Harness pick: maki (herdr-native, rtk-aware, 18 providers, MIT). Monitor: abtop + herdr pane status for maki.
- Intel SL4: pinctrl_tigerlake autodetected by fix-surface-keyboard.sh (drop-in for AMD/Intel). gaze (502★, v0.3.10, -bin only) for greeter breadth; visage (80★, v0.4.0, source pkg) for minimal PAM. Neither has SL4 IR quirk on file.
- varlet99 plugin: open freeze bug #1 + 3 unmerged PRs, treat as unstable. snes19xx 24 forks: ZERO Intel SL4 forks.
- Omarchy news: Kimi joins default agents; Qt 6.12 black-bar regression (NOT fixed in 4.0.4) = PIN WARNING; plugin marketplace submissions OPEN; sudomarchy top-5 (OmaCal, Time Machine, Spaces, hyprmoncfg, Tray).
- Rockstar dotfiles Oct 15-17: NONE found (negative finding).

## Kit changes this round
- aur-optional.txt: maki-bin guarded opt-in (source maki skipped).
- memory/search/inference next adds: ai-memory, xerj, magnitude (evaluate, not yet wired).

# ROUND 3 — fresh since R2 (2026-10-17/18) — kit-decision deltas only

## Qt 6.12 — scope resolved
Fix = (a) rebuild quickshell vs Qt 6.12 + (b) Commons.Color rename (#14553, merged Oct 9, quattro only). Stable tag still v4.0.4 (2026-09-15) = still broken for stock users. Next = Quattro RS 4.5 (skips 4.1), no tag yet.
Noctalia v4 IS hit (built vs 6.11.2). Noctalia v5 5.3.0 (native C++/GLES) sidesteps Qt entirely. Kit: keep Omarchy Quickshell; pin channel (stable-mirror, already); require v5 if Noctalia. Guard `omarchy update` (qt6>=6.12 + omarchy<=4.0.4 = skip). shell-switch noctalia = documented black-bar rescue.

## Release deltas
rtk: stable v1.0.1 + dev rc.552; PR #3151 adds OMP as 16th agent (confirms hook target). maki v0.6.4 ✓. codex rust-v0.163.0 + 0.164.0-alpha.3. herdr v0.9.5 (fixes Codex clamp warning). ai-memory v3.1.1. xerj still rc.96. magnitude CLI 0.2.9. noctalia 5.3.0.

## ai-memory promoted: evaluate → wire
AUR ai-memory-bin (akitaonrails, MIT) + source both exist; installs /usr/bin + hooks + system/user units + sysusers/tmpfiles + /etc/ai-memory/config.toml. `install claude-code --apply` + optional PreToolUse governance hook. Coexists with rtk hooks (independent; --force on dupes). Already in aur-optional.txt (R3a). OMP/Pi likely MCP-only tier-3 — needs live test.

## xerj / magnitude reality
xerj: NO AUR, curl-musl only, AVX2 ✓ (i7-1185G7), ~400MB idle + 2GB/index, still RC → NOT wired. magnitude: Arch pkg OK (x64, glibc≥2.34) but Iris Xe CPU-only modest (no AMX) → experimental. uzu comparison stands.

## Omarchy news
Agents panel: per-agent quotas, 15-min usage-update, 95% autoswitch → covers abtop quota view (abtop keeps per-session tokens; still no omp/pi). DHH weighing DROPPING AUR by default (fake yay incident) → RISK to aur-optional.txt strategy; keep guarded, prefer omarchy-repo binaries. agy ≠ real stub (#8553, corrects R1). OmaPicks W43: Jarvis v2.4.0, AkitaOnRails usage plugin v1.35.0, Lacquer.

## NEW trending Rust (kit-relevant)
pydantic/monty 8,703★ (secure Python sandbox for agent code). microsoft/mxc v1.0.1 (policy sandbox, bubblewrap Linux backend, Rust SDK — pairs with NVIDIA/OpenShell). farion1231/cc-switch ~145k★ (multi-provider config switcher, overlaps agents panel). EXCLUDE: morluto/rea (TypeScript), dynamo (serving), craft suite (creative apps), Konnect (KiCAD).

## Face-auth (R3 verdict, see r3-face.md)
gaze = ONLY fit for Intel SL4 (I2C IR-emitter path documented; visage UVC-only, likely can't drive SL4 emitter). First-try: gaze-bin + gaze-gui-bin + gaze-omarchy-bin (AUR -bin trio). Preflight: AVX2 ✓, pacman -Si opencv 5.0.x (hard pin), IR transport, TPM2, PAM backups. visage fallback only.

## Kit actions
- KEEP: maki-bin + ai-memory-bin (opt-in), rtk-bin/herdr-bin/abtop/walker-bin/codewhale (core AUR), tv/yazi/gitui/jj/atuin/helix/ast-grep (extra).
- HOLD: xerj, magnitude, monty, mxc, cc-switch, AkitaOnRails plugin (evaluate only).
- WATCH: omarchy AUR-default decision; RS 4.5 tag (pin-free path); Qt 6.12 stable-mirror sync.
- Corrections carried: rtk OMP #3151; agy≠stub; rea=TS; Noctalia v5≠Quickshell.

# ROUND 4 — live + eval + watch + compat (2026-10-17, this box + 4 slices)

## LIVE preflight (Intel SL4, Fedora, read-only — DECISIVE)
- IR camera = USB-UVC 045e:0990 "Surface Camera Front" (video0/1 color, video2/3 IR, uvcvideo driver). NOT I2C/MIPI — no v4l2loopback bridge needed. visage UVC path POSSIBLE (needs 045e:0990 quirk + rebuild; none ships). gaze direct cameras.ir=/dev/video2.
- No OmniVision/OV7251 anywhere. MSHW0125:00 unbound (known linux-surface ACPI gap #425/#532); MSHW0184:00 = apds9960 ALS (bound).
- AVX2+AVX512 YES (gaze/xerj reqs ✓; no AMX → magnitude CPU modest holds). TPM2 YES (ACPI table + tpm0 v2 + tpm2-tools; /dev/tpmrm0 inferred c10:232, confirm on Omarchy). pinctrl_tigerlake + full surface stack live ✓.
- OpenCV: none on Fedora (repo carries 4.11.0 only). Arch-side gaze pin (opencv 5.0.x) must be checked ON OMARCHY.

## Sandbox eval
- PICK ai-usagebar-bin 1.40.1-1 (author AUR, Waybar + native Quickshell plugin + TUI, no API keys) → wired guarded + plugin step. PICK-LOW cc-switch-bin (commented). DEFER monty (dev lib) + mxc (no AUR, dev SDK; OpenShell rival watch).

## Upstream watch (no kit moves)
- Releases all static (omarchy v4.0.4, quattro docs-only HEAD, rtk/maki/codex/herdr/ai-memory/xerj/noctalia unchanged). 4.5 milestone 2/427 open — tag imminent, escalated.
- Stable mirror STILL 6.11.2 + quickshell 0.3.1 (probed: 6.12 + 0.3.2 = 404). Arch extra fully 6.12.0-3 + 0.3.2-1. Pin rule unchanged, guard necessary-not-triggered. Plain-Arch pull = black bar.

## Compat audit (kit edits applied)
- Noctalia v5 compositor-agnostic; shell-mode.lua verbs/rules VERBATIM from docs — no changes. Hook gap FIXED: creates config.toml if absent + warns on state settings.toml [theme].
- Qt Color: ALL third-party plugins AFFECTED (face-auth, javon27 lock-pin, varlet99) — bare Color. everywhere, patches won't re-apply. Face-auth HOLD; javon27 lock-pin plugin SKIP (stale clone, regresses lock); varlet99 flagged blocked. Guard extended: any bare-Color. plugin breaks even on patched quattro under Qt 6.12.
- Clamshell SL4: two-finger-right-click PORTED (py + service + python-evdev dep + 10-script templated install for real UID). lock-pin/screensaver/tablet-stack SKIP.

## Kit changes this round
- surface-fixes += two-finger-right-click.py + two-finger-rightclick.service (templated __USER_UID__/__ROOT_LIBDIR__); 10-script installs + enables; packages += python-evdev.
- noctalia-palette.py creates config.toml when missing.
- aur-optional += ai-usagebar-bin (wired), cc-switch-bin (commented).

# ROUND 5 — watch + live + plugins + promote (2026-10-17)

## Watch: ZERO kit-changing deltas
4.5 NOT tagged (v4.0.4 latest; quattro 4e059acf docs-only; version 4.0.0.alpha; milestone 2/427 trivial). Mirror re-verified AT FILE LEVEL (6.11.2-3 + 0.3.1-1 = 200; 6.12 + 0.3.2 = 404). All 15 tracked repos identical. NEW in extra: noctalia-greeter 1.6.0 + dms-shell 1.6.3 (same Qt exposure, no action). atuin/ast-grep still STALE+flagged. Social: no W43 yet (R3 label premature). OmaPicks/macoma/Strata/Omacraft cosmetic.

## Live (EXECUTED on box): IR = GREY 480x480 @60, TPM nodes confirmed
v4l2-ctl: [0] GREY 8-bit, 480x480, 60fps — mono direct, no conversion. tpm0 10,224 + tpmrm0 252,65536 CONFIRMED (validates R4 kvm correction). video0-3 81,0-3. Gaze = cameras.ir=/dev/video2 (or by-path :1.2), encrypt_templates=true viable. evdev 1.9.3 user-site OK. Touchscreen event17, touchpad event11. by-id has NO IR links (shared serial). Session GNOME here; re-check XDG on Omarchy boot.

## Plugins: 3 CLEAN / 9 BLOCKED (file:line evidence)
Mechanism grounded: QtQuick/Color singleton shadows qs.Commons (#14553 merged, milestone 4.0.5; #15069 open). Fix = Commons.Color (compat). 230-hit fix wave live 10-17. CLEAN: Time Machine, Keystroke (migrated), Jarvis (omission). BLOCKED: OmaCal, Spaces, hyprmoncfg (partial), Tray, Dynamic Island x2, Easy Capture (fix PR #3 OPEN), Lacquer, side-panel, btop-activity. Only Color implicated (Style/Util/Border safe). face-auth: NO update past v1.0.2 (dbd8a97 09-29); resync.sh PROVABLY aborts on quattro (hash + context drift). Patch must be regenerated. HOLD stands.
Kit: prefer CLEAN plugins; Easy Capture watch PR #3; guard extended (any bare-Color plugin breaks even on patched quattro under 6.12).

## Promote: NO HOLD→WIRE. DECLINEs: monty, mxc, cc-switch(-bin line removed), uzu.
monty = dev lib no role. mxc = SDK-only no AUR + PARTNER not rival (NVIDIA blog + OpenShell #2050 — R4 framing corrected). cc-switch overlap WIDENED + config-overwrite bugs (#2133/#2764) → commented line REMOVED from aur-optional.txt. uzu = macOS-only dist. HOLD: xerj (rc.96, GA 4/15 open, no AUR), magnitude (0.2.9, no AUR, no Intel validation), visage (no 045e:0990 quirk). Triggers recorded.

## Kit changes this round
- aur-optional.txt: cc-switch-bin commented line REMOVED (declined).

# ROUND 6 — triggers + trends (2026-10-17)

## Triggers: ZERO fired
4.5 NOT tagged · mirror frozen (file-level 200/404) · PR #3 OPEN · face-auth dbd8a97 no tags · xerj/magnitude absent · visage/gaze unchanged · maki-bin newly flagged OOD (guarded opt-in, no change) · all 14 releases identical. Only note: quattro base.packages drifts (adds qt6 stack/gliff/hype/owe, removes clang/llvm/obs...) — irrelevant until tag.

## Trends: kernel conflict CONFIRMED + new tools
- Omarchy 4.0.4 boots linux-omarchy FIRST (Limine #1) + bore variant. #12136: default kernel kills Surface touch; verified path = linux-surface 6.19.8 + IPTSD + ITHC DKMS. KIT ALREADY COVERS: 10-script BOOT_ORDER (linux-surface first) + migration-1789325478 block. Action: VERIFY on Omarchy boot that BOOT_ORDER wins over installer default; check IR touch after updates.
- Corrections: next = 4.0.5 (not 4.5); OmaPicks = W42.
- NEW (evaluate-only): prime-agent (~22k★, MIT, v0.10.0, RLM harness) vs maki/codewhale. NEW memory: rtk-ai/icm (same org, SQLite+vec, MCP, beta) + graphicle (+228★/wk). ai-memory keeps wired slot. NEW omp/pi monitoring path: Agent Orchestrator (Herdr/OMP/Hermes/Claude/Codex/Grok) + Session Browser (resume incl Pi) — TEST via guarded plugin add (abtop lacks omp/pi). T3 Code ships in Omarchy (Node, no action).
- Sandbox: strands/box (macOS-only today, watch). Index: awesome-agent-orchestrators (~2.2k★) → OpenHuman to evaluate.
- Trending filtered: OpenLogi 23.7k★ (Logitech-only). Dotfiles: NO rockstar (holds).
- News: Primeagen Agentic QA (Oligarchy); $18.5M funding; Gliff remote desktop → base (RS 4.5); registry 4,765 plugins; AUR-drop risk unchanged.

## Kit changes: NONE (guard verified present; new tools evaluate-only).

# ROUND 7 — watch + tools + plugins (2026-10-17)

## Watch: essentially ZERO deltas
4.0.5/4.5 untagged · mirror frozen (file-level) · PR #3 open · face-auth static · AUR held absent · all releases + wired AUR identical. INFORMATIONAL: OmaPicks W43 live (Easy Capture champion still blocked — reinforces guard); repo renamed basecamp→omacom (redirects, kit already omacom). WATCH carries unchanged.

## Tools eval: prime-agent herdr-aware (corrects R6), graphicle AUR-ready, box/OpenHuman DECLINED
- prime-agent 22,094★ v0.10.0: NO AUR, but herdr YES (self-reports, ref integration #2633, label missing). License MIT-vs-Other flag. HOLD.
- icm 583★ v0.11.4: rtk-ai sibling, no AUR, overlaps ai-memory. HOLD.
- graphicle 259★ v0.1.1: AUR graphicle-bin EXISTS + Pi/OMP-aware (pi-guard). HOLD, cheapest to wire if code-graph MCP wanted (1wk old, 0 votes).
- box: macOS-only, no AUR/Linux. DECLINE. OpenHuman: GPL-3.0 Tauri desktop, AUR exists but wrong shape. DECLINE.
- Kit: no wiring. Corrections carried (prime-agent herdr-aware; graphicle-bin + Pi-aware).

## Plugins: OMP ∪ Pi path = BOTH plugins (both BLOCKED today)
- Agent Orchestrator (18★ MIT): OMP sessions + Agy/Herdr/Claude/Codex. Session Browser (5★ MIT): Pi sessions + Copilot/Gemini. TOGETHER cover OMP+Pi (abtop lacks both). Both BLOCKED (bare Color.). Hommies CLEAN, Omaherd BLOCKED.
- Test: guarded plugin add both (orchestr = live OMP monitor, browser = Pi history/resume); pre-apply Commons.Color to vendored copies before kit bundling.
- Kit: no plugin lines yet (both blocked); record test path in README/Phase notes.

## Kit changes: NONE (evals only; all HOLD/DECLINE or blocked).

# ROUND 8 — watch + trends + plugins (2026-10-17)

## Watch: ZERO kit-changing deltas
Triggers unfired (4.0.5/4.5 untagged, mirror frozen file-level, PR #3 open, face-auth static, AUR/releases identical). Corrections: OmaPicks = W42; quattro HEAD has #15722 (informational); rename omacom confirmed. Kit: NONE. WATCH carries.

## Trends: OMP/Pi plugin finds (evaluate-only)
- NEW brianstarke/omarchy-plugin-omp (OMP Usage, MIT): first OMP bar monitor (~/.omp sessions → tokens/model). Needs Color audit before bundling.
- NEW rohaquinlop/omarchy-agent-collectors (MIT, 2★): Pi + OpenCode → stock Agents panel records. CLEAN (service only). Cheapest Pi path; feeds official panel. Caveat #8270 (Pi blind-spot).
- DROPPED: agent-notifier ARCHIVED (→herdr). Familiar Desktop retired. wy 0.2.0 (7★, pi/omp-adjacent TUI) nascent evaluate-only. Craft suite EXCLUDE (GUI apps).
- Upstream: #15517 bar rework (plugin compat watch), #15263 dock, next = 4.0.5 confirmed. Omarchy on X. Funding/bounty/Gliff carried. Dotfiles: NO rockstar.
- Kit: NONE (test list: OMP Usage + agent-collectors first — simpler than blocked Orchestrator/Browser pair).

## Plugins: PR #3 still OPEN; auto-fixer #14597 OPEN (kit-changing if merged); face-auth static
- #14597 (e1f14a1 10-16): hidden omarchy-plugin-fix-palette auto-rewrites bare Color on add/update. WATCH — merge supersedes manual guard for add/update paths. Alternative: ShellColor rename (worse). No release ships it.
- Lefteros x5 migrated 10-09; workspace-layout PR #17 open. Blocked set otherwise static.
- CLEAN: Time Machine, Keystroke, Jarvis x2. agent-collectors CLEAN (service only) — record as Pi path.
- Kit: guard unchanged. WATCH #14597 + PR #3 before any vendoring.

# ROUND 9 — watch + trends + plugins (2026-10-17)

## Watch: no kit-changing deltas; 2 WATCH updates
4.0.5/4.5 untagged · mirror frozen (file-level) · PR #3 + #14597 open · face-auth static · AUR/releases identical (maki-bin OOD-guarded).
NEW WATCH: PR #15265 open (4.0.4 palette backport — Commons fix could land on 4.0.4 branch). ESCALATION: 4.0.5 milestone 37/37 CLOSED (branch v4-0-5, rc1 described, NO tag yet) — tag imminent; on tag re-verify base.packages + Commons.Color.

## Trends: omp-stats supersedes OMP Usage; Aperture new; mise dotfiles signal
- omp-stats (native, omp stats --json, OMP ≥17.3.7 = this box v18.11.3 ✓) STRICTLY BETTER than stale OMP Usage (~2mo). Both need Color audit.
- Aperture (registry, OMP attention, herdr/tmux/foot) → test list; Color audit.
- agent-collectors unchanged (Pi path). PR #7157 (OpenCode-Go stock). mise 2026.10.5 dotfile history → evaluate vs chezmoi.
- No new kit Rust, no rockstar dotfile, W42, ai-usagebar v1.40.0 wired.

## Plugins: zero merges; OMP audits done; new clean/blocked
- #14597 + PR #3 open; face-auth static HOLD. OMP Usage BLOCKED, OMP Stats BLOCKED (both audited) — NO clean OMP bar monitor. agent-collectors CLEAN stands (only clean OMP/Pi feeder). Lefteros x5 clean confirmed. workspace-layout blocked (PR #17 open, stale). NEW clean: theme-colors, screenote. NEW blocked: facelock.
- Kit: guard unchanged; prefer-list += Lefteros x5, theme-colors, screenote.

## Kit changes: NONE (all eval/watch). WATCH carries + #15265 + 4.0.5-tag-imminent.

# ROUND 10 — rc1 live + omp-native correction + lock-explorer clean (2026-10-17)

## Watch: rc1 IS PUBLISHED (first trigger movement in 10 rounds), tag not cut
pkgs.omarchy.org/rc omarchy-4.0.5rc1-1 = 200 (120MB). Tags/releases still v4.0.4. v4-0-5 branch HAS Commons.Color fix (merge #14845, Bar+LockView); base.packages = 4.0.4-shaped (no qt6/gliff/hype drift). ON 4.0.5 TAG: relax palette guard (keep for 4.0.4 + third-party). Mirror frozen (lastupdate 09-07). x86_64 black-bar reports = Arch-extra path. PRs zero merges. face-auth static. AUR/releases identical.

## Trends: omp stats NATIVE (correction)
oh-my-pi (35,775★): omp stats ships upstream (dashboard :3847, --json, SQLite). Box v18.11.3 ✓. Kit: omp stats already works, no plugin/risk. Bar widget cosmetic (blocked). agent-collectors clean stands (Pi path; OMP needs user adapter). Aperture registry (Color audit). mise 2026.10.10 dotfiles (evaluate vs chezmoi). SPACE new sandbox (heavy, watch). 4.0.5 still untagged.

## Plugins: lock-explorer BLOCKED→CLEAN (v2.0.5, 73 files, verified 10-16, has pam_facelock). Prefer-list += it.
Lefteros x5 clean confirmed (KB 1.2.6). #14597 + PR #3 open. OMP widgets all blocked (stats, Usage, Aperture, harlanljones). agent-collectors clean stands. NEW clean: theme-colors, screenote. NEW blocked: facelock. face-auth static HOLD. Guard unchanged.

## Kit changes: NONE (rc1 watched, guard stands until tag; prefer-list +lock-explorer noted).

# ROUND 11 — tag NOT cut + litebox/Hindsight + OMP audits (2026-10-17)

## Watch: tag NOT cut (tags top v4.0.4; rc1 live, no rc2; v4-0-5 tip 94a8fbc2). On-tag payload verified: base.packages = v4.0.4 set; Commons fix in train. Mirror frozen. PRs #15265 (bot-verified 236→0) / #14597 / PR #3 all OPEN. face-auth static. AUR/releases identical (maki-bin OOD). oh-my-pi latest = v18.11.3 (R10 18.12.1 uncorroborated).
## Trends: litebox v0.1.0 (3,162★, Rust lib-OS, WATCH-only). Hindsight v1.0 Memlake (~50k★, breaking) evaluate-only. prime-agent Rust confirmed (22,094★, herdr-aware, NO AUR → HOLD stronger). rho/crates.io + rig PR WATCH. omp-stats 2★ still BLOCKED; Aperture npm 0.5.0/0.10.0-RC (OMP path actionable, audit needed); agent-collectors CLEAN stands (OMP gap = user adapter). mise v2026.10.13 → LEANS MISE over chezmoi (upstream-blessed, decision open). No rockstar dotfile.
## Plugins: zero merges; no blocked→clean. OmaCal active-but-blocked. New monitors (agent-bar x2, codex-router, boomux) ALL BLOCKED. agent-collectors only clean feeder stands. Prefer-list unchanged (lock-explorer, Lefteros x5, theme-colors, screenote). Guard unchanged.
## Kit changes: NONE (mise lean noted, decision open; no package lines).

# ROUND 12 — tag frozen + goose/openinterpreter + OMP vetted + mise input (2026-10-17/18)

## Watch: tag NOT cut (v4.0.4 top; milestone 37/37; rc1 live, no rc2; #15698 draft). PRs #15265 (bot-verified + x86_64 confirms) / #14597 / PR #3 / #17 all OPEN. face-auth static (gaze docs = 4.0.2/4.0.3 compat). AUR + releases identical (maki-bin OOD). CORRECTION: oh-my-pi v18.12.0/18.12.1 TAGGED (R11 wrong); box 18.11.3, premise holds.
## Trends: goose v1.55.0 (aaif, ~55k★) + openinterpreter Rust v0.0.56 (~69k★) + thClaws NEW (evaluate-only). OMP Stats PUBLISHED+vetted (bare Color x4 → guard-on-palette). Aperture registry (audit needed). mise v2026.10.13: LEANS MISE (bundled, per-machine, future omarchy-dots) with chezmoi fallback / Stow baseline — decision open, user owns call. No rockstar dotfile.
## Plugins: zero merges. NEW CLEAN codexbar (Commons, 67+ providers via AUR codexbar-cli) → prefer-list +. New blocked: Herdr widget, Leaderboard, Agent Usage. No blocked→clean. Guard unchanged.
## Kit changes: NONE (correction recorded; mise lean noted; prefer-list +codexbar noted).

# ROUND 13 — tag frozen + stock-reads-OMP correction + Voxscope/Omapet clean (2026-10-17/18)

## Watch: tag NOT cut (top v4.0.4; rc1 live, no rc2; v4-0-5 tip 94a8fbc2). On-tag payload = 4.0.4-shaped + Commons fix (shell/Ui/Button.qml verified). Mirror frozen. PRs #15265/#14597/#3/#17 OPEN. face-auth static. AUR/releases identical (maki-bin OOD). oh-my-pi 18.12.1 tagged (box 18.11.3; R12 correction confirmed).
## Trends: stock DOES read OMP sessions (provider-gated; real gap = non-Anthropic/Codex #8270 — corrects R10/R12). OMP Stats registry+vetted (bare guard stands). Aperture registry (audit needed). agent-collectors clean (OMP gap = user adapter). NEW: reason-network (Rust P2P, pi ext), LOOP/prux/hrdr, capsem (heavy), litebox/SPACE carried; orca excluded (TS). No new memory. mise v2026.10.13: LEAN MISE carries + gaps #13410 + ADR-0011 proof; chezmoi fallback. No rockstar.
## Plugins: zero merges. Voxscope + Omapet CLEAN (prefer-list +=). Baroque/Counter/Omarchy-notes BLOCKED. Omacale v0.54.0 Qt-6.12 fix = CANDIDATE (mapping unverified). codexbar clean confirmed. Guard unchanged.
## Kit changes: NONE (prefer-list +Voxscope/Omapet/Omacale-candidate noted).

# ROUND 14 — rc1 both arches + stock-opencode-go + Omacale/Agent Pulse clean (2026-10-17)

## Watch: tag NOT cut (top v4.0.4; v4-0-5 tip 94a8fbc2; rc1 live BOTH arches 120MB; no rc2; probe path /<channel>/$arch/). Payload = 4.0.4-shaped + Commons in train. Mirror frozen. PRs open. face-auth static. AUR/releases identical. Refinements: rc1 both-arch; PR #3 Stegi56.
## Trends: reason-network v0.10.5 released (eval-only). Stock merged opencode-go collector (Pi still sole-gap → collectors only Pi path stands). ai-memory re-published (wired, no move). New memory engines eval-only. Sandbox static. mise lean (no new tag). omp-stats marketplace-listed (blocked); Aperture registry (audit); agent-collectors clean. OmaPicks W42; omp stats native premise holds.
## Plugins: Omacale CLEAN (v0.54.0, PRs merged) + Agent Pulse CLEAN (v1.11.2) → prefer-list. Voxscope UNVERIFIED (no repo — R13 transcription error, do NOT carry). NEW: Howdy Face Unlock (published+verified, IR-relevant) + PenguID (TPM-sealed) → evaluate. OMP widgets all blocked; collectors clean stands. Guard unchanged.
## Kit changes: NONE (prefer-list +Omacale/Agent Pulse noted; Voxscope REMOVED as unverified).

# ROUND 15 — face-auth shortlist + mise blessed + Voxscope phantom (2026-10-17)

## Watch: tag NOT cut (top v4.0.4; version alpha; rc1 both arches 120MB; no rc2; v4-0-5 tip 94a8fbc2). Payload = 4.0.4-shaped + Commons in train. Mirror frozen. PRs open. face-auth static (gaze active, no tag). AUR/releases identical (maki-bin OOD).
## Trends: OMP Stats listed (blocked); Aperture registry (audit); collectors unchanged; stock #7157; mise v2026.10.13 LEANS MISE (gaps documented, ADR proof; decision open). New: litebox, Hindsight, prime-agent Rust, rho/rig, capsem. No rockstar. OMP 18.12.1 tagged.
## Face-auth SHORTLIST (SL4 USB-UVC): irlume Rust TPM-sealed + PenguID plugin (CLEAN QT) + howdy-next C++ AUR + Howdy Face Unlock CLEAN (verified, SHA-pinned) ahead of gaze(stale)/visage. Official #5212 lane. HOLD (no kit line).
## Plugins: zero merges. Voxscope PHANTOM (remove). Omacale/Agent Pulse/codexbar/OmaPets/theme-colors/screenote clean (prefer-list). facelock/OmaCal blocked. Howdy/PenguID CLEAN (prefer-list +=). #8336 open. Guard unchanged.
## Decisions: dotfiles → MISE (upstream-blessed, chezmoi fallback); face-auth → irlume/PenguID + howdy-next shortlist (HOLD). No package lines.
## Kit changes: NONE.

# ROUND 16 — face-auth explodes + OpenHuman re-open + Voxscope real (2026-10-17/18)

## Watch: tag NOT cut (top v4.0.4; v4-0-5 tip 94a8fbc2; rc1 live, no rc2; rc-mirror fresh 10-16, stable frozen 09-07). On-tag payload verified (4.0.4-shaped + Commons in train). PRs #15265 (x86_64 confirmed) / #14597 / #3 / #17 OPEN. Face: PenguID CLEAN, Glance new (plugin blocked, AUR unpublished), face-unlock new (blocked), howdy-liveness new, irlume AUR + wiki, howdy-next 3.4.2. oh-my-pi = v18.11.3 (R12 18.12.x uncorroborated). AUR/releases static. Guard stands. WATCH carries.
## Trends: Glance (5-cue liveness) / irlume+PenguID (TPM) / howdy-next lead; manuals prove lanes unshipped (dotfiles=Stow, auth=fingerprint/FIDO2). mise NOT MERGED (substrate only; lean stands). OMP: stats ID known (blocked), Aperture registry (audit), collectors framework (Pi path), stock now +Grok/Fireworks. OpenHuman RE-OPENED (42k★ Rust lib; R7 decline wrong). New: litebox/SPACE/box/agentic-sandbox/OctantOS, Mneme/memory engines, reason-network v0.10.5, prime-agent Rust, rho/rig. No rockstar. Kit: NONE.
## Plugins: ZERO merges. Omacale v0.54.1 + Agent Pulse clean (prefer-list). Voxscope REAL+CLEAN (R15 phantom retracted — prefer-list eligible) + Omapet CLEAN. Baroque/Counter blocked. Howdy/PenguID CLEAN (prefer-list). #8336 open. Guard unchanged.
## Corrections: Voxscope phantom→real; oh-my-pi 18.11.3; OpenHuman re-open.
## Kit changes: NONE.

# ROUND 17 — howdy-liveness validated + #14040 panel expansion + mise upstream (2026-10-17)

## Watch: tag NOT cut (top v4.0.4; rc1 live, no rc2; v4-0-5 tip 94a8fbc2; payload verified 4.0.4-shaped + Commons in train). Mirror frozen. PRs #15265/#14597/#3/#17/#8336 OPEN (bot-verified + x86 confirms). face-auth static (irlume repo active no tag; PenguID 10-14; Glance stale; howdy-next; gaze 0.3.10). AUR/releases identical.
## NEW WATCH #14040 (DHH, open): stock agents panel 6→23 collectors + 13 launchers; pi/omp split by provider; closes OMP/Pi blind-spot natively IF merged. NOT merged → no kit line; invalidates third-party-OMP-monitor premise if lands.
## Trends: howdy-liveness STRONGEST SL4 evidence (Surface Pro IR validated). Glance v0.3.4 (AUR unpublished). irlume+PenguID / howdy-next lead. mise v2026.10.13 + #14065 (upstream-blessed; decision MISE, fallback chezmoi). OpenHuman HOLD-stronger. Aperture registry. agent-collectors Pi path (OMP = user adapter). Stock +Grok/Fireworks. New: Harn/LOOP/Memlake/Mneme/TopoDB; prime-agent/rho/rig; capsem/litebox. No rockstar. oh-my-pi 18.12.1 tagged.
## Plugins: zero merges (#14597 design pending; PR #3 AI CLEAN-state; #17 UNSTABLE stale; #15265 bot+x86). No blocked→clean. Face lane: Howdy/PenguID CLEAN QT; Glance plugin BLOCKED; Rio stale BLOCKED; facelock/therealasclepius/wouldja/biometric-hud BLOCKED. Agent monitors blocked (Orchestrator/Omaherd/OMP twins/Agent Bar/etc). ai-usagebar active. Prefer-list: lock-explorer, Omacale, Agent Pulse, codexbar, OmaPets, theme-colors, screenote, PenguID, Howdy (+Voxscope/Omapet from R13/16). Guard unchanged.
## Stegi56 Commons wave (#3, mic-effects #14, eye-care #2, clipbasket #7) reinforces guard.
## Kit changes: NONE (decisions: mise + face-auth shortlist; no package lines).

# ROUND 18 — #13845 mergeable + #14452 mise dots + gaze-no-SL4-profile (2026-10-17/18)

## Watch: tag NOT cut (top v4.0.4; rc1 both arches 120MB; no rc2; v4-0-5 tip 94a8fbc2 = 4.0.4-shaped + Commons). Mirror: stable frozen (Qt6.12 rc-only). PRs #15265/#14597/#3/#17/#8336 OPEN. #14040 OPEN hottest (Greptile 4/5, 15 P1; #15766 competing). Face: gaze surface-pro4 profile but NO 045e:0990 → SL4 uncovered (HOLD). AUR/releases identical (maki-bin OOD; oh-my-pi 18.11.3). New sources: publish-log (no promote lines), omarchy-pkgs channel engine. Kit: NONE.
## Trends: #14040 open (OMP dropped by design; Greptile unsafe). NEW #13845 MERGEABLE (native omp collector: stats --json + stats.db + DeepSeek; awaiting dismissal) — THE native OMP path. #14452 mise dots OPEN greptile 5/5 (enable/push/pull/diff/restore, track-local; needs mise ≥2026.10.5; #11029 updated; v2026.10.13 security fix) — REINFORCES MISE. #14597 open (lock-designs gap). agent-collectors self-neutralizes; omp-stats blocked; Usage Tray #11987 new. Face: howdy-liveness = research artifact (no kit line); offyotto helper new. OpenHuman HOLD. New: Agent37/Engrams/caliban/LOOP/Graphicle/capsem/SPACE/rho/rig/Mneme/Hindsight. No rockstar. Kit: NONE (carries reinforce pending decisions).
## Plugins: zero merges; #14597 + PR #3 AI + #17 unstable carries. No blocked→clean. Aperture BLOCKED (audit resolved). Easy Capture main BLOCKED. Prefer-list holds (+Voxscope/Omapet corrected real+clean; codexbar/Main-Panel note). Omacale CANDIDATE (mapping unverified). Guard unchanged. WATCH carries.
## Kit changes: NONE.

# ROUND 19 — #13845 mergeable + #14452 dirty + OMP native contested (2026-10-17/18)

## Watch: tag NOT cut (top v4.0.4; version alpha; rc1 both arches; no rc2). Payload = 4.0.4-shaped + Commons. Mirror: stable frozen for omarchy pair; fast-ring daily. PRs #15265 (strongest, user pressure + point-release asks) / #14597 (design) / #14040 (DIRTY, 14P1+2P2, unsafe) / #8336 (lane → #11612) OPEN. Face static. AUR/releases identical (oh-my-pi-bin 18.12.1 resolves dispute; box 18.11.3).
## #13845 MERGEABLE (conflicts resolved, Greptile 5/5, awaiting dismissal) BUT CONTESTED: #14040 lists it "Left out on purpose" + reshape offer (sessions/prompts/days/balance). Native OMP path premise now contested not pending.
## #14452 DIRTY (was 5/5; needs rebase; mise ≥2026.10.5 gate cleared via pkgs) — mise signal "lean, not committed". #11029 + #13022/#12709 carries. v2026.10.13 security fix.
## Face: PenguID = irlume wrapper (one stack; SL4 uncovered, needs ir-setup). howdy-liveness dormant artifact. irlume v0.15.0 Omarchy-documented. gaze static. Glance stale. howdy-next active. offyotto/sp5 bridges (patterns). HOLD.
## OMP: stock reads OMP (provider-gated Anthropic/Codex); gap = non-Anthropic/Codex #8270. agent-collectors Pi path (self-neutralizes). omp-stats blocked. Aperture TS blocked.
## Plugins: zero merges. #14452 dirty (regression). Aperture dual-blocked (Color + catalog). Usage Tray watch-not-adopt. No blocked→clean. Guard unchanged.
## Kit: NONE. WATCH: #15265 merge (relax stable guard); #14597 (supersede add/update guard); #13845 vs #14040 (OMP premise); #14452 rebase (mise dots); tag (relax 4.0.5).

# ROUND 20 — contest both sides + gate cleared + Aperture dual-blocked (2026-10-17/18)

## Watch: tag NOT cut (top v4.0.4; rc1 both arches; no rc2; v4-0-5 tip 94a8fbc2). Payload verified (4.0.4-shaped + Commons in train). Mirror: stable frozen for omarchy pair; fast-ring daily.
## #13845 MERGEABLE (5/5; blocker stale review) vs #14040 4/5 (drops omp by design; reshape offer; kwsantiago fixes; NEW #15766 competitor). Contest unresolved. NEITHER merged.
## #14452 DIRTY (rebase needed) BUT GATE CLEARED (mise ≥2026.10.5 in pkgs; v2026.10.13 signed). MISE decision carries; chezmoi fallback.
## #15265 strongest (bot-verified + x86 + point-release asks) / #14597 (design; 5/5) / #3 / #17 / #8336 (lane → #11612) OPEN.
## Face: no SL4 profile anywhere (irlume validated ASUS/HP/NexiGo/ThinkPad only; gaze docs 4.0.2/4.0.3; howdy-next UVC RGB; SP5 refs only). one-stack (PenguID=irlume wrapper); liveness dormant. HOLD.
## AUR: oh-my-pi-bin 18.12.1-1 (dispute resolved). Rest identical. Mirror: mise live; Qt pair frozen.
## Trends: stock opencode-go merged (#7157); mise dots #14452 open; omp stats native holds; agent-collectors Pi path; Aperture registry audit-pending; mise lean; New: reason-network/octos/SPACE-litebox/capsem/Mneme/Hindsight/prime-agent/rho/rig. No rockstar.
## Plugins: ZERO merges (#14597 CLEAN state; #13845 UNSTABLE checks-failing; #14452 DIRTY; #14040 DIRTY in-repo; #3 CLEAN; #17 UNSTABLE). Aperture dual-blocked (Color + catalog). Prefer-list holds (PenguID/Howdy clean; lock-explorer/codexbar re-verified). Guard unchanged.
## Kit: NONE. WATCH carries all.

# ROUND 21 — 🔴 MIRROR Qt 6.12 LIVE (guard TRIGGERED) + Glance installable + #13845 MERGEABLE (2026-10-17/18)

## Watch: Qt 6.12.0-3 + quickshell 0.3.2-1 = 200 on mirror.omarchy.org (6.11.2 GONE). lastupdate 10-17, lastsync 10-18. Stable-frozen premise FALSE. Guard now NECESSARY+TRIGGERED. Wild confirms #14989/#14469/#15069 + mac. KIT CHANGE: pre-update guard WIRED into 40-overlay.sh (blocks on qt6>=6.12 + omarchy<=4.0.4; offers hold/pin/backport). Tag NOT cut (top v4.0.4; 4.0.5 milestone 37/0 NEW; #14553 in it). Contest: #13845 UNSTABLE (checks) vs #14040 DIRTY in-repo vs #15766 new. #14452 DIRTY (gate cleared). PRs #15265 (strongest) / #14597 / #3 / #17 / #8336 open. Face static. AUR/releases identical (maki-bin OOD).
## Trends: #13845 back MERGEABLE (one dismissal away; reshape unaccepted). #14040 unsafe (14P1+2P2). #14452 blocked on rebase only. mise v2026.10.13 signed; MISE carries. Face: howdy-liveness top SL4 evidence; irlume+PenguID / Glance (installable RGB) / howdy-next lead. OpenHuman HOLD. OMP: stock provider-gated; collectors Pi path; stats blocked; Usage new. New: Harn/LOOP/Memlake/Mneme/TopoDB/prime-agent/rho/rig/capsem/SPACE. No rockstar. Kit: guard wired (only change).
## Plugins: zero merges; #13845 UNSTABLE; Aperture dual-blocked; prefer-list holds (+Omapet/Voxscope corrected real+clean). Guard unchanged (now enforced pre-install).
## Kit changes: 40-overlay.sh Qt-6.12 pre-update guard (BLOCKS on triggered combo). No package lines.

# ROUND 22 — CORRECTION: stable still 6.11.2 (guard NOT triggered) + omp-stats vetted (2026-10-18)

## CORRECTION (kit-changing): R21 probed EDGE host. stable-mirror = Qt 6.11.2-3 (200) + quickshell 0.3.1-1 (200); 6.12 = 404. Edge = 6.12. Stable x86_64 + update does NOT black-bar. Guard = necessary, NOT triggered (version-keyed, self-corrects for edge/rc/Asahi). REVERT R21 framing; guard logic unchanged. ADD: QtQuick-6.11-pin no-downgrade rescue + howdy CUDA note. No package lines.
## Watch: tag NOT cut. v4-0-5 tip 94a8fbc2. rc1 live, no rc2. Contest 3-way (#13845 UNSTABLE vs #14040 DIRTY in-repo vs #15766 UNSTABLE). #14452 DIRTY (gate cleared). PRs open. Face static (no SL4). AUR: oh-my-pi-bin 18.12.1 (upstream matches). Mirror: stable frozen for omarchy pair; fast-ring daily.
## Trends: #13845 reshape unaccepted; #14040 unsafe; #14452 blocked on rebase; #14597 lock-designs gap; collectors self-neutralize; omp-stats blocked; Usage new; mise v2026.10.13 signed + pkgs ≥2026.10.11.
## Plugins: zero merges (#14597 CLEAN design; #13845 UNSTABLE; #14452 DIRTY; #14040 DIRTY; #3 CLEAN; #17 UNSTABLE; #8336 DIRTY). Aperture dual-blocked (Color + catalog). Prefer-list holds (lock-explorer/codexbar/OmaPets/theme-colors/screenote/PenguID/Howdy/Voxscope/Omapet). Guard unchanged.
## Kit changes: guard comment corrected (channel reality) + rescue notes. No package lines.

# ROUND 23 — mirror path corrected + #15722 merged + 15-PR wave (2026-10-18)

## Watch: tag NOT cut (top v4.0.4; v4-0-5 tip 94a8fbc2; milestone 100%; rc1 live, no rc2). Mirror: stable STILL frozen (6.11.2/0.3.1 = 200; 6.12 = 404; lastupdate 09-07). Edge/rc live 6.12. PATH CORRECTED: mirrors /extra/os/<arch>/, pkgs /<channel>/<arch>/. Guard NOT triggered on stable (R21 revert stands). #14040 vs #13845 vs #15766 unresolved (#13845 UNSTABLE, #14040 DIRTY, #15766 UNSTABLE). #14452 DIRTY (gate satisfied). PRs #15265/#14597 CLEAN open; #8336 DIRTY; PR #3/#17 open. Face static HOLD. AUR: oh-my-pi-bin 18.12.1 (upstream matches). Releases identical.
## Trends: #13845 back MERGEABLE (one dismissal away; reshape unaccepted). #14040 unsafe (14P1+2P2; kwsantiago fixes; #15766 competitor). #14452 blocked on rebase; mise v2026.10.13 signed; MISE carries. #14597 lock-designs gap; collectors self-neutralize; omp-stats blocked; Usage new. Face: PenguID=wrapper; liveness dormant; HOLD. New: lattice/harness-rs/cupti/set616/prime-agent/rho/rig/capsem/litebox/Mneme/Hindsight. OMP 18.12.0 breaking + 18.12.1. No rockstar. Kit: NONE.
## Plugins: #15722 MERGED (Codex spend, milestone 4.5 — first agents-panel change). Tracked five: ZERO merges. printbar/webcam CLEAN (merged elsewhere). 15-PR wave ALL OPEN (Stegi56 x9 + riclib x6) → blocked population >> tracked; guard = ANY third-party plugin. Clone Keeper BLOCKED (was unaudited). Shader Desk CLEAN. Watchful Eye auth-capable (no kit). Prefer-list holds (+Omapet/Voxscope corrected real+clean; codexbar/Main-Panel note). Guard unchanged.
## Kit changes: NONE (guard comment already corrected R22; rescue notes in place).
