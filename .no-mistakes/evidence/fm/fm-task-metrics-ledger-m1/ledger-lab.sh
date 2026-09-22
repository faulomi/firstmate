#!/usr/bin/env bash
# Live lab: real bin/fm-spawn.sh + bin/fm-teardown.sh on an isolated fm-lab-* Herdr
# session with a scratch FM_HOME, then show data/crew-dispatch/task-ledger.md.
set -u
ROOT=/Users/jerome/.no-mistakes/worktrees/f380a11d9129/01M344CNZ7YZE3A3YTQN9452VG
. "$ROOT/tests/herdr-test-safety.sh"
herdr_forget_inherited_pane
TMP_ROOT=$(mktemp -d "$(cd "${TMPDIR:-/tmp}" && pwd -P)/fm-ledger-lab.XXXXXX")
SESSION=$("$ROOT/bin/fm-herdr-lab.sh" name ledger)
export HERDR_SESSION="$SESSION"
WTS=()
cleanup_all() {
  for w in "${WTS[@]}"; do [ -n "$w" ] && treehouse return --force "$w" >/dev/null 2>&1; done
  herdr_safe_stop_and_delete "$SESSION"; echo "lab teardown rc=$? session=$SESSION"
  rm -rf "$TMP_ROOT"
}
trap cleanup_all EXIT
fm_herdr_lab_prepare "$SESSION" || { echo "prepare failed"; exit 1; }
echo "lab session: $SESSION"
H="$TMP_ROOT/home"; mkdir -p "$H/state" "$H/data" "$H/config"
printf 'off\n' > "$H/config/herdr-presentation-spaces"
P="$TMP_ROOT/proj"; mkdir -p "$P"; git -C "$P" init -q -b main
printf '# s\n' > "$P/README.md"; git -C "$P" add README.md
git -C "$P" -c user.name=T -c user.email=t@e.invalid commit -qm init
git clone -q --bare "$P" "$P.origin.git"; git -C "$P" remote add origin "file://$P.origin.git"
git -C "$P" fetch -q origin
brief() { mkdir -p "$H/data/$1"; printf '# Task\n## Captain'"'"'s intent\nLedger lab %s.\n\n## Firstmate spec\nDo nothing.\n%s\n' "$1" "${2:-}" > "$H/data/$1/brief.md"; }
spawn() { local id=$1; shift
  FM_SPAWN_NO_GUARD=1 FM_HOME="$H" FM_ROOT_OVERRIDE="$ROOT" "$ROOT/bin/fm-spawn.sh" "$id" "$@" --backend herdr >"$TMP_ROOT/$id.spawn.out" 2>&1
  local rc=$?; echo "spawn $id rc=$rc"; [ $rc -eq 0 ] || tail -20 "$TMP_ROOT/$id.spawn.out"
  local wt; wt=$(grep '^worktree=' "$H/state/$id.meta" 2>/dev/null | cut -d= -f2-); WTS+=("$wt")
  echo "--- state/$id.meta (ledger-relevant fields)"; grep -E '^(kind|mode|harness|model|effort|spawned_at|relaunches|project)=' "$H/state/$id.meta"; }
teardown() { FM_ROOT_OVERRIDE="$ROOT" FM_STATE_OVERRIDE="$H/state" FM_DATA_OVERRIDE="$H/data" FM_CONFIG_OVERRIDE="$H/config" FM_HOME="$H" \
  "$ROOT/bin/fm-teardown.sh" "$@" >"$TMP_ROOT/td.out" 2>&1; local rc=$?; echo "teardown $* rc=$rc"; tail -4 "$TMP_ROOT/td.out"; return $rc; }
ledger() { echo "--- data/crew-dispatch/task-ledger.md"; cat "$H/data/crew-dispatch/task-ledger.md" 2>/dev/null || echo "(absent)"; }
st() { printf '%s\n' "$2" >> "$H/state/$1.status"; }

echo; echo "=== S1 ship local-only, model/effort explicit, done line -> row"
brief lshipa 'Delivery contract: mode=local-only'
spawn lshipa "$P" "sh -c 'echo lshipa-ok; sleep 600'" --mode local-only --yolo off --model opus --effort high
ledger
st lshipa "done [at=$(date +%s)]: nothing to land"
teardown lshipa; ledger

echo; echo "=== S2 ship no-mistakes with unlanded work, no done: refused teardown writes no row; forced writes exactly one 'discarded'"
brief lshipb 'Delivery contract: mode=no-mistakes'
spawn lshipb "$P" "sh -c 'sleep 600'" --mode no-mistakes --yolo off --model sonnet --effort medium
WTB=$(grep '^worktree=' "$H/state/lshipb.meta" | cut -d= -f2-)
echo x > "$WTB/work.txt"; git -C "$WTB" add work.txt; git -C "$WTB" -c user.name=T -c user.email=t@e.invalid commit -qm work
teardown lshipb; echo "rows for lshipb after refused teardown: $(grep -c '^| lshipb ' "$H/data/crew-dispatch/task-ledger.md")"
teardown lshipb --force; echo "rows for lshipb after forced teardown: $(grep -c '^| lshipb ' "$H/data/crew-dispatch/task-ledger.md")"
ledger

echo; echo "=== S3 scout, default model/effort, report + done -> row with report path"
brief lscout
spawn lscout "$P" "sh -c 'sleep 600'" --scout
printf '# Report\n' > "$H/data/lscout/report.md"
st lscout "done [at=$(date +%s)]: report written"
FM_STATE_OVERRIDE="$H/state" FM_DATA_OVERRIDE="$H/data" FM_CONFIG_OVERRIDE="$H/config" "$ROOT/bin/fm-captain-hold.sh" complete lscout --none >/dev/null; echo "captain-hold complete rc=$?"
teardown lscout; ledger

echo; echo "=== S4 ship local-only relaunched once via fm-control -> attempt 2"
brief lshipc 'Delivery contract: mode=local-only'
spawn lshipc "$P" "sh -c 'echo first; exit 0'" --mode local-only --yolo off --harness claude --model opus --effort low
sleep 3
FM_HOME="$H" FM_ROOT_OVERRIDE="$ROOT" FM_STATE_OVERRIDE="$H/state" FM_DATA_OVERRIDE="$H/data" FM_CONFIG_OVERRIDE="$H/config" \
  "$ROOT/bin/fm-control.sh" lshipc relaunch --note "lab retry" >"$TMP_ROOT/rl.out" 2>&1; echo "relaunch rc=$?"; tail -8 "$TMP_ROOT/rl.out"
echo "--- state/lshipc.meta after relaunch"; grep -E '^(harness|model|effort|spawned_at|relaunches|spawn_gen)=' "$H/state/lshipc.meta"
st lshipc "done [at=$(date +%s)]: ok"
teardown lshipc; ledger
