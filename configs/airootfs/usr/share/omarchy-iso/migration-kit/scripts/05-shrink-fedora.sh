#!/usr/bin/env bash
# Shrink Fedora's btrfs root (nvme0n1p3) to TARGET_GIB while Fedora runs.
# Order matters: shrink the filesystem first, then the partition. If interrupted
# after step 1, the filesystem still fits inside the partition, so nothing is lost.
# Dry run unless --apply is given. Run as root: sudo scripts/05-shrink-fedora.sh [--apply]
set -euo pipefail

DISK=/dev/nvme0n1
PART_NUM=3
PART=${DISK}p${PART_NUM}
TARGET_GIB=120
TARGET_MIB=$((TARGET_GIB * 1024))
MIN_HEADROOM_PCT=85   # refuse if used data is above this share of the target

APPLY=0
CONFIRMED=0
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=1 ;;
    --confirmed) CONFIRMED=1 ;;
    *) echo "usage: $0 [--apply [--confirmed]]" >&2; exit 2 ;;
  esac
done

say() { printf '[shrink] %s\n' "$*"; }
die() { printf '[shrink] STOP: %s\n' "$*" >&2; exit 1; }
step() {
  if ((APPLY)); then say "RUN: $*"; "$@"; else say "DRY: $*"; fi
}

[[ $EUID -eq 0 ]] || die "run as root (sudo)"

# --- checks: these must all pass before anything changes ---------------------
ROOT_SRC=$(findmnt -no SOURCE / | sed 's/\[.*//')
[[ $ROOT_SRC == "$PART" ]] || die "root is $ROOT_SRC, expected $PART"
findmnt -no FSTYPE / | grep -qx btrfs || die "root is not btrfs"

used_b=$(btrfs filesystem usage -b / | awk '/Used:/{print $2; exit}')
used_mib=$((used_b / 1024 / 1024))
min_b=$(btrfs inspect-internal min-dev-size / | awk '{print $1}')
min_mib=$((min_b / 1024 / 1024))
size_b=$(blockdev --getsize64 "$PART")
size_mib=$((size_b / 1024 / 1024))

say "partition $PART: ${size_mib} MiB"
say "btrfs used: ${used_mib} MiB, minimum possible size: ${min_mib} MiB"
say "target: ${TARGET_MIB} MiB (${TARGET_GIB} GiB)"

((TARGET_MIB < size_mib)) || die "target is not smaller than the current partition"
((min_mib <= TARGET_MIB)) || die "btrfs minimum ${min_mib} MiB is above target"
((used_mib * 100 <= TARGET_MIB * MIN_HEADROOM_PCT)) || die "used data above ${MIN_HEADROOM_PCT}% of target"

devid=$(btrfs filesystem show / | awk '/devid/{print $2; exit}')
[[ -n $devid ]] || die "could not read btrfs devid"

# Partition start and new end, in MiB, from the current table
start_mib=$(parted -s "$DISK" unit MiB print | awk -v n="$PART_NUM" '$1==n{gsub("MiB","",$2); print int($2); exit}')
[[ -n $start_mib ]] || die "could not read partition start"
new_end_mib=$((start_mib + TARGET_MIB))

say "plan:"
say "  1. btrfs filesystem resize ${devid}:${TARGET_GIB}G /   (online, data relocates)"
say "  2. parted resizepart ${PART_NUM} ${new_end_mib}MiB   (partition end; takes effect at reboot)"
say "  3. reboot, then check: lsblk ${DISK}; btrfs filesystem show /"

if ((!APPLY)); then
  say "dry run only. Re-run with --apply to make these changes."
  exit 0
fi

if ((!CONFIRMED)); then
  read -r -p "[shrink] type SHRINK to proceed: " confirm
  [[ $confirm == SHRINK ]] || die "confirmation not given, nothing changed"
fi

step btrfs filesystem resize "${devid}:${TARGET_GIB}G" /
step btrfs filesystem show /
if ((APPLY)); then
  # parted refuses a mounted partition under -s; answer its warning explicitly.
  say "RUN: parted resizepart ${PART_NUM} ${new_end_mib}MiB (answering the in-use warning)"
  printf 'Yes\nYes\n' | parted ---pretend-input-tty "$DISK" resizepart "$PART_NUM" "${new_end_mib}MiB"
else
  say "DRY: parted resizepart ${PART_NUM} ${new_end_mib}MiB"
fi
say "done. Reboot now, then run: lsblk ${DISK}"
