#!/usr/bin/env bash
# Render the literal codex launch command fm-spawn.sh sends to the pane for a
# ship crewmate, a scout, and a secondmate (fake tmux captures send-keys -l),
# then run the real codex CLI with the crew flag set to show memories resolves off.
set -u
cd "$1"
eval "$(sed -n '1,122p' tests/fm-spawn-dispatch-profile.test.sh | sed 's|$(dirname "${BASH_SOURCE\[0\]}")|tests|')"
for kind in ship scout secondmate; do
  id=live-codex-$kind-z9
  rec=$(make_spawn_case live-$kind codex "$id"); read_case_record "$rec"
  case $kind in
    ship) run_ship_spawn "$HOME_DIR" "$WT_DIR" "$FAKEBIN_DIR" "$LAUNCH_LOG" "$id" "$PROJ_DIR" >/dev/null ;;
    scout) run_spawn "$HOME_DIR" "$WT_DIR" "$FAKEBIN_DIR" "$LAUNCH_LOG" "$id" "$PROJ_DIR" --scout >/dev/null ;;
    secondmate) sm="$CASE_DIR/secondmate-home"; make_seeded_secondmate_home "$sm" "$id"
      run_spawn "$HOME_DIR" "$WT_DIR" "$FAKEBIN_DIR" "$LAUNCH_LOG" "$id" "$sm" --secondmate >/dev/null ;;
  esac
  echo "--- $kind spawn exit=$? ; launch command sent to pane:"; cat "$LAUNCH_LOG"; echo
  printf '    contains --disable memories: '; grep -q -- '--disable memories' "$LAUNCH_LOG" && echo yes || echo no
done
echo
echo "--- real $(codex --version): crew flag set, features list (no prompt submitted)"
codex --dangerously-bypass-approvals-and-sandbox --disable hooks --disable memories features list 2>&1 | grep -E '^(memories|hooks|codex_hooks) '
echo "--- real codex, no flags (operator's own config untouched):"
codex features list 2>&1 | grep -E '^memories '
echo "--- operator config [features] memories line:"
grep -E '^\s*memories\s*=' "${CODEX_HOME:-$HOME/.codex}/config.toml"
