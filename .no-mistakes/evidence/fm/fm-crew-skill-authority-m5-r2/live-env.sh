#!/bin/bash
set -eu
ROOT="$PWD"
LAB="$ROOT/.nm-memory-lab"
export FM_HOME="$LAB/home" FM_ROOT_OVERRIDE="$LAB/runtime" CODEX_HOME="$LAB/codex"
export TREEHOUSE_ROOT="$LAB/pool" TMPDIR="$LAB/tmp" SHELL=/bin/bash
export PATH="$LAB/tools:/opt/homebrew/bin:/Users/jerome/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export FM_GATE_REFUSE_BYPASS=1 FM_SPAWN_NO_GUARD=1 FM_BACKEND=tmux
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null
export GIT_AUTHOR_NAME=Smoke GIT_AUTHOR_EMAIL=smoke@example.invalid GIT_COMMITTER_NAME=Smoke GIT_COMMITTER_EMAIL=smoke@example.invalid
unset TMUX TMUX_PANE CLAUDECODE PI_CODING_AGENT FM_TASK_ID
# Isolate tool runtime state in a per-command HOME, without changing the caller's HOME.
exec env HOME="$LAB/user" bash "$1"
