#!/usr/bin/env bash
# Shared prompt helpers. Source this; do not run it.
#   ASSUME_YES=1       answer yes to normal prompts (set by 00-postinstall.sh --auto)
#   INCLUDE_OPTIONAL=1 in auto mode, also say yes to optional/opt-in prompts
# Safety checks inside the scripts are never skipped by these helpers.

: "${ASSUME_YES:=0}"
: "${INCLUDE_OPTIONAL:=0}"

# confirm "question": normal step. Auto mode = yes.
confirm() {
  if [[ $ASSUME_YES == 1 ]]; then echo "$1 [auto: yes]"; return 0; fi
  local a; read -rp "$1 [y/N] " a; [[ $a == y ]]
}

# confirm_optional "question": opt-in step. Auto mode = no unless INCLUDE_OPTIONAL=1.
confirm_optional() {
  if [[ $ASSUME_YES == 1 ]]; then
    if [[ $INCLUDE_OPTIONAL == 1 ]]; then echo "$1 [auto: yes, --include-optional]"; return 0; fi
    echo "$1 [auto: no]"; return 1
  fi
  local a; read -rp "$1 [y/N] " a; [[ $a == y ]]
}

# confirm_risky "question": always asks a human unless AUTO_RISKY=1 is set explicitly.
confirm_risky() {
  if [[ ${AUTO_RISKY:-0} == 1 ]]; then echo "$1 [AUTO_RISKY: yes]"; return 0; fi
  if [[ $ASSUME_YES == 1 ]]; then echo "$1 [auto: no, needs a human]"; return 1; fi
  local a; read -rp "$1 [y/N] " a; [[ $a == y ]]
}
