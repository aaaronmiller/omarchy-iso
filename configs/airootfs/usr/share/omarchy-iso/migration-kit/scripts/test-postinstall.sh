#!/usr/bin/env bash
# Stub harness for 00-postinstall.sh. Touches nothing outside a temp dir under the job dir.
set -u
S=~/code/omarchy-migration/scripts/00-postinstall.sh
T=$(mktemp -d "${CLAUDE_JOB_DIR:-$HOME/.cache}/pitest.XXXX")
export STATE_DIR=$T/state AUTOSTART_FILE=$T/autostart.desktop
pass=0; fail=0
chk() { if eval "$2"; then echo "PASS $1"; pass=$((pass+1)); else echo "FAIL $1"; fail=$((fail+1)); fi; }

echo "--- dry run on stock kernel"
out=$(KERNEL_RELEASE=6.19.0-arch1 bash "$S" --auto --dry-run 2>&1); echo "$out" | tail -8
chk "dry run writes no state" "[[ ! -e $STATE_DIR/state ]]"
chk "dry run plans stage 1" "grep -q 'DRY: .*10-omarchy-surface.sh' <<<\"\$out\""
chk "dry run plans resume entry" "grep -q 'DRY: write' <<<\"\$out\""

echo "--- dry run on surface kernel"
out=$(KERNEL_RELEASE=6.19.0-surface bash "$S" --auto --dry-run 2>&1)
chk "plans finalize" "grep -q -- '--finalize' <<<\"\$out\""
chk "plans packages" "grep -q '40-overlay.sh' <<<\"\$out\""
out=$(KERNEL_RELEASE=6.19.0-surface bash "$S" --auto --dry-run --no-finalize 2>&1)
chk "--no-finalize skips finalize" "grep -q 'skipped (--no-finalize)' <<<\"\$out\""
chk "bad flag exits 2" "bash '$S' --nope >/dev/null 2>&1; [[ \$? == 2 ]]"

echo "--- lib-auto semantics"
src="source ~/code/omarchy-migration/scripts/lib-auto.sh"
chk "auto: confirm yes" "bash -c '$src; ASSUME_YES=1; confirm q' >/dev/null"
chk "auto: optional no" "! bash -c '$src; ASSUME_YES=1; confirm_optional q' >/dev/null"
chk "auto+include: optional yes" "bash -c '$src; ASSUME_YES=1 INCLUDE_OPTIONAL=1; confirm_optional q' >/dev/null"
chk "auto: risky no" "! bash -c '$src; ASSUME_YES=1; confirm_risky q' >/dev/null"
chk "interactive: n answers no" "! bash -c '$src; confirm q' <<<n >/dev/null"
chk "interactive: y answers yes" "bash -c '$src; confirm q' <<<y >/dev/null"

echo "--- no stray prompts left in the automated scripts"
chk "no read -rp in 10/40/30" "! grep -n 'read -rp' ~/code/omarchy-migration/scripts/{00-postinstall,10-omarchy-surface,40-overlay,30-desktop}.sh | grep -v -e lib-auto -e 'Press Enter'"
echo "pass=$pass fail=$fail (temp: $T)"
[[ $fail == 0 ]]
