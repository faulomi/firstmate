#!/usr/bin/env bash
# Live lab: real bin/fm-spawn.sh + bin/fm-teardown.sh on an isolated fm-lab-* Herdr
# session with a scratch FM_HOME, then show data/crew-dispatch/task-ledger.md.
set -u
ROOT=/Users/jerome/.no-mistakes/worktrees/f380a11d9129/01M344CNZ7YZE3A3YTQN9452VG
. "$ROOT/tests/herdr-test-safety.sh"
herdr_forget_inherited_pane
TMP_ROOT=$(mktemp -d "$(cd "${TMPDIR:-/tmp}" && pwd -P)/fm-ledger-lab.XXXXXX")
SESSION=$("$ROOT/bin/fm-herdr-lab.sh" name ledger2)
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


echo; echo "=== S4b ship local-only, agent exits, fm-spawn --relaunch twice on the stopped task -> relaunches=2, attempt 3"
brief lshipd 'Delivery contract: mode=local-only'
spawn lshipd "$P" "sh -c 'echo first; exit 0'" --mode local-only --yolo off --model opus --effort low
for n in 1 2; do
  sleep 3
  FM_SPAWN_NO_GUARD=1 FM_HOME="$H" FM_ROOT_OVERRIDE="$ROOT" "$ROOT/bin/fm-spawn.sh" lshipd --relaunch >"$TMP_ROOT/rl$n.out" 2>&1; echo "relaunch $n rc=$?"; tail -6 "$TMP_ROOT/rl$n.out"
  echo "--- state/lshipd.meta after relaunch $n"; grep -E '^(harness|model|effort|spawned_at|relaunches|spawn_gen)=' "$H/state/lshipd.meta"
done
st lshipd "done [at=$(date +%s)]: ok"
teardown lshipd; ledger

echo; echo "=== S5 secondmate retirement writes no ledger row"
SM="$TMP_ROOT/smhome"; mkdir -p "$SM/state" "$SM/data" "$SM/config" "$SM/projects" "$SM/bin"
printf 'off\n' > "$SM/config/herdr-presentation-spaces"; printf '# placeholder\n' > "$SM/AGENTS.md"
printf 'lsm1\n' > "$SM/.fm-secondmate-home"; printf 'charter: nothing.\n' > "$SM/data/charter.md"
FM_SPAWN_NO_GUARD=1 FM_HOME="$H" FM_ROOT_OVERRIDE="$ROOT" "$ROOT/bin/fm-spawn.sh" lsm1 "$SM" "sh -c 'sleep 600'" --secondmate --backend herdr >"$TMP_ROOT/sm.out" 2>&1; echo "spawn lsm1 rc=$?"; tail -5 "$TMP_ROOT/sm.out"
grep -E '^(kind|harness)=' "$H/state/lsm1.meta"
before=$(wc -l < "$H/data/crew-dispatch/task-ledger.md")
teardown lsm1 --force
after=$(wc -l < "$H/data/crew-dispatch/task-ledger.md"); echo "ledger lines before=$before after=$after; lsm1 rows=$(grep -c '^| lsm1 ' "$H/data/crew-dispatch/task-ledger.md")"
ledger
