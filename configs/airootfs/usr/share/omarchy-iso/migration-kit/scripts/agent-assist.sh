#!/usr/bin/env bash
# Launch a post-install helper agent from agent-prompts/. Nothing runs without --agent.
#   agent-assist.sh list
#   agent-assist.sh show <name>
#   agent-assist.sh run <name> --agent [--dry-run]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
P="$ROOT/agent-prompts"
MODEL="${AGENT_MODEL:-claude-sonnet-5-5}"
cmd="${1:-list}"; name="${2:-}"

case $cmd in
  list) for f in "$P"/*.md; do b=$(basename "$f" .md); [[ $b == README ]] && continue; printf '%-16s %s\n' "$b" "$(sed -n 1p "$f" | sed 's/^# //')"; done ;;
  show) cat "$P/$name.md" ;;
  run)
    [[ -f $P/$name.md ]] || { echo "no such prompt: $name (try: list)" >&2; exit 2; }
    [[ " $* " == *" --agent "* ]] || { echo "Refusing: pass --agent to start a Claude session ($name)." >&2; exit 2; }
    mkdir -p "$ROOT/reports"
    # Read-only prompts get read-only tools; the others get an interactive session where each tool call is approved by the user.
    if grep -q '^Mode: read-only' "$P/$name.md"; then
      args=(-p --model "$MODEL" --permission-mode default --add-dir "$ROOT" --allowedTools "Read,Grep,Glob,Bash(ls:*),Bash(cat:*),Bash(uname:*),Bash(lsmod:*),Bash(pacman -Q:*),Bash(pacman -Si:*),Bash(systemctl --failed:*),Bash(systemctl status:*),Bash(journalctl:*),Bash(hyprctl:*),Bash(libinput:*),Bash(v4l2-ctl:*),Bash(stat:*),Bash(git status:*),Bash(git clone:*),Bash(rg:*),Bash(bash -n:*),Bash(shellcheck:*),Write($ROOT/reports/*)")
    else
      args=(--model "$MODEL" --add-dir "$ROOT")
    fi
    if [[ " $* " == *" --dry-run "* ]]; then echo "DRY: env -u ANTHROPIC_API_KEY claude ${args[*]} < $P/$name.md"; exit 0; fi
    # Interactive mode takes the prompt as an argument; -p reads it from stdin.
    if [[ ${args[0]} == -p ]]; then env -u ANTHROPIC_API_KEY claude "${args[@]}" <"$P/$name.md"
    else env -u ANTHROPIC_API_KEY claude "${args[@]}" "$(cat "$P/$name.md")"; fi ;;
  *) echo "usage: $0 list | show <name> | run <name> --agent [--dry-run]" >&2; exit 2 ;;
esac
