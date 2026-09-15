set -eu
ROOT="$PWD"
LAB="$ROOT/.nm-memory-lab"
"$ROOT/bin/fm-spawn.sh" live-sm "$LAB/secondmate" --secondmate --harness codex
for id in raw-codex raw-env raw-other; do
 mkdir -p "$LAB/home/data/$id"
 cp "$LAB/home/data/live-scout/brief.md" "$LAB/home/data/$id/brief.md"
done
"$ROOT/bin/fm-spawn.sh" raw-codex "$LAB/project" --scout 'codex features list'
"$ROOT/bin/fm-spawn.sh" raw-env "$LAB/project" --scout 'env -- FOO=bar codex features list'
"$ROOT/bin/fm-spawn.sh" raw-other "$LAB/project" --scout 'env /bin/echo RAW_NON_CODEX_PRESERVED'
