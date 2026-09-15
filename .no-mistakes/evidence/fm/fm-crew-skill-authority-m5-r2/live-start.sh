set -eu
ROOT="$PWD"
LAB="$ROOT/.nm-memory-lab"
git -C "$LAB/project" init -q
git -C "$LAB/project" commit -q --allow-empty -m fixture
tmux -f /dev/null new-session -d -s firstmate -x 140 -y 45 -c "$LAB/project"
tmux set-option -g default-shell /bin/bash
tmux set-option -g default-command '/bin/bash --noprofile --norc'
"$ROOT/bin/fm-spawn.sh" live-scout "$LAB/project" --scout --harness codex
"$ROOT/bin/fm-spawn.sh" live-ship "$LAB/project" --mode direct-PR --yolo off --harness codex --model gpt-5 --effort high
