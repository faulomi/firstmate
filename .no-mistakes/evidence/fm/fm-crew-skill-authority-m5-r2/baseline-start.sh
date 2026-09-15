set -eu
LAB="$PWD/.nm-memory-lab"
mkdir -p "$LAB/home/data/base-scout"
cp "$LAB/home/data/live-scout/brief.md" "$LAB/home/data/base-scout/brief.md"
bash "$LAB/baseline/bin/fm-spawn.sh" base-scout "$LAB/project" --scout --harness codex
