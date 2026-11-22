> Snapshot baked into the ISO at build time. Latest: ~/code/omarchy-iso/research/ (FINAL-REPORT.md, LEDGER.md).

# Ledger: Omarchy on Surface Laptop 4 (updated 2026-10-18)

Read this before ending any turn. A round is "done" only when consolidated into CONSOLIDATED-REPORT.md.

## Targets
| Target | Asked | Done | Status |
|---|---|---|---|
| Custom ISO, Surface kernel, on the stick | 1 | 1 (sha256 237fe033..., stick copy matches) | DONE, untested on hardware |
| Research: web searches | 250 | about 30 direct by me; omp ran 23 rounds / about 60 agents (API-verified) | NOT MET by count; omp covers depth |
| Research: consolidated report | 1 | CONSOLIDATED-REPORT.md (merges omp and mine) | DONE; per-bullet source tags pending |
| Lost reports recovered | all | 70 omp + 16 mine (two independent recoveries) | DONE (recovered-best/) |
| Dotfiles overlay (best of each, no duplicates) | 1 | dotfiles/ tested on a throwaway home | DONE on Fedora; untested on Omarchy |
| Appearance switching (live where possible) | 1 | shell-switch + Omarchy picker + palette hook, documented | DONE in code; untested on Omarchy |
| Periodic review | weekly | cron job (session-only) | see below |

## Blockers (only the user can clear)
- B1. Boot the stick on the laptop and report the screen (Ventoy never appeared in the last test; try a direct port, no adapter).
- B2. ai-root `pkg-install` fails on dnf5 (the `--` argument). Fix needs a root install (password dialog).
- B3. OpenCode and OpenAI API keys are expired or invalid; omp/Codex runs that need them cannot start. Rotate them yourself.
- B4. Reddit pages are blocked to the search tool. Official route: a Reddit API app under your own account.
- B5. Sonnet recovery run hit the usage limit (resets 3:50am Vancouver) and left no manifest/comparison. Its recovered files were compared by hash (tools/compare-recoveries.py): omp 70/70 identical; research files superset of mine; adopted in recovered-best/. A re-run would only add its self-written manifest.

## Decisions waiting on the user
- D1. stow (chosen, my review) vs chezmoi (omp's lean).  D2. Face login: gaze vs pb3975 (on hold, Qt 6.12).
- D3. Re-enable two-finger right-click after a code review?  D4. Which of omp's extra packages (rtk, abtop, yazi...).
- D5. Rename the two secrets files back?  D6. Clear 2.7 GB of rofi core dumps; drop the rofi autostart?

## Open work
- DONE 2026-10-18: Noctalia palette hook warns on a GUI [theme] in the state file (config.toml was already created if absent). Tested in a throwaway home: creates config, writes palette, warns, idempotent.
- DONE 2026-10-18: live Ghostty wheel multiplier restored to precision:1,discrete:3 (changelog entry added).
- DONE 2026-10-18: weekly review job verified present (session-only, next run Mon Oct 19 ~9:37, expires after 7 days).
- report-lint (source tag per bullet) not built; the consolidated report predates the tagging rule.

## 2026-10-18 automation pass
- DONE: post-install automation (scripts/lib-auto.sh, 00-postinstall.sh --auto/--dry-run/--no-finalize/--resume), tested with scripts/test-postinstall.sh (14/14).
- DONE: agent-prompts/ (7) and scripts/agent-assist.sh (needs --agent).
- DONE: extras split out of default package lists (D4 stays open). Noctalia is in Arch extra.
- DONE: research/FINAL-REPORT.md. Kit tarball rebuilt and copied to the Ventoy stick.
- OPEN (user): install tools/ai-root.fixed via pkexec (command in tools/INSTALL-ai-root-fix.txt); boot test; D1-D4.

## 2026-10-18 pre-reboot check
- DONE: ai-root fixed installed (cmp identical, pkg-install git ok, option injection rejected).
- DONE: stick holds our ISO (sha256 237fe033..cd28 matches SHA256SUMS-quattro.txt; tools/status.sh --iso says DONE), turnkey.sh, kit tarball (38d14e1ad0973c0e).
- DONE: Secure Boot disabled (mokutil); secrets files mode 600; linux-surface key fingerprint matches; surface repo db reachable (HTTP 200).
- OPEN (user): boot test; D1 stow (decided), D2 face login = gaze first (user said yes), D3 two-finger click stays off, D4 extras via scripts/50-extras.sh; rofi core dumps (2 listed) and rofi autostart; renew OpenAI/OpenCode keys; diverged/dirty repos; stick is 97% full (1.9 GB free).
- NOT AUDITED: content accuracy of Sonnet/omp recovered reports (hash-compared only).

## 2026-10-18 turnkey rebuild
- DONE: kit baked into the ISO (installer phase stage_migration_kit, first-login autostart, machine-wide migration marker); build 1 exit 0, status DONE, sha256 40d434ac...1f40; kit inside image identical to source (tree hash 0dad9c1e).
- DONE: stick updated and verified by checksum (ISO, tarball, turnkey.sh, 00-NEXT-AGENT-PROMPT.md). Old 10.17 ISO removed from the stick only after its identical local copy was confirmed.
- DONE: package dedupe against Omarchy's bundled set; completion prompt rewritten; preflight check 6; unit tests (5) and stub tests (7 + 14) pass.
- DONE: ai-root fixed installed. Content claims audited: tools/audit-claims.sh.
- OPEN (user): boot test of build 1 on the laptop; two-finger right-click review; extras choice; Fedora housekeeping; keys.
- OPEN (me, optional): content audit of recovered omp/Sonnet reports beyond hashes; Noctalia IPC verbs vs source.
