#!/bin/sh
# each-commit.sh VOCCLONE [FROM]: check out each commit of master..series
# in a worktree of VOCCLONE (from the FROMth on), build it with make all,
# and report whether the confidence tests pass. Logs stay in the worktree's
# parent directory.
[ $# -ge 1 ] || { echo "usage: $0 VOCCLONE [FROM]" >&2; exit 2; }
V=$(cd "$1" && pwd); FROM=${2:-1}
W=$(mktemp -d); git -C "$V" worktree add -q --detach "$W/voc" series || exit 1
cd "$W/voc"; n=0
for c in $(git -C "$V" rev-list --reverse master..series); do
  n=$((n+1)); [ $n -lt "$FROM" ] && continue
  git checkout -q "$c"
  if (make clean; make all INSTALLDIR="$W/install") > "$W/log.$n" 2>&1 &&
     grep -q 'Confidence tests passed' "$W/log.$n"
  then echo "$n ok   $(git log -1 --format=%s)"
  else echo "$n FAIL $(git log -1 --format=%s)"
  fi
done
echo "logs in $W; remove the worktree with: git -C $V worktree remove --force $W/voc"
