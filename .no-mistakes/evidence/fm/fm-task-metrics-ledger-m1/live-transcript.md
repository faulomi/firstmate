# Live Herdr lab transcript (session fm-lab-ledger-91982-25609, isolated FM_HOME, real fm-spawn.sh + fm-teardown.sh, real treehouse pool)

## ledger-ship: spawn --model opus --effort high; first spawn writes spawned_at
spawned ledger-ship harness=sh kind=ship mode=no-mistakes yolo=off window=fm-lab-ledger-91982-25609:w1:p2 worktree=/Users/jerome/.treehouse/project-7cbf40/1/project
(meta had spawned_at=1790067492)

## ledger-ship: non-forced teardown refused (unpushed work); ledger dir absent afterwards -> no row
REFUSED: worktree /Users/jerome/.treehouse/project-7cbf40/1/project has work not on any remote and not landed.
unpushed commits:
37aab58 work
Push the branch, land its PR, or get the captain's explicit OK to discard, then --force.

## ledger-ship: after push, teardown with 'done corr=<hex>' status line
teardown ledger-ship complete (window fm-lab-ledger-91982-25609:w1:p2, worktree /Users/jerome/.treehouse/project-7cbf40/1/project)

## ledger-forced: --force with unlanded work
teardown ledger-forced complete (window fm-lab-ledger-91982-25609:w2:p2, worktree /Users/jerome/.treehouse/project-7cbf40/1/project)

## ledger-refused: pushed but status log ends 'blocked', no done line
teardown ledger-refused complete (window fm-lab-ledger-91982-25609:w3:p2, worktree /Users/jerome/.treehouse/project-7cbf40/1/project)

## ledger-scout: scout spawn --model sonnet --effort medium, report + done
teardown ledger-scout complete (window fm-lab-ledger-91982-25609:w4:p2, worktree /Users/jerome/.treehouse/project-7cbf40/1/project)

## lg: secondmate retirement -> ledger line count unchanged (8 -> 8), no '| lg ' row
teardown lg complete (window fm-lab-ledger-91982-25609:w5:p2, worktree /private/var/folders/71/gpt_mxqn5b339ydgdzq6w4xw0000gn/T/fm-ledger-live.dO96VT/home-2ndmate-lg)

## ledger-rl: ledger file chmod 444 -> forced teardown rc=0, warning, meta removed, ledger unchanged
teardown: reaping leaked worktree process(es) for ledger-rl: 33665 38250
teardown: force-killing leaked worktree process(es) for ledger-rl: 33665
/Users/jerome/.no-mistakes/worktrees/f380a11d9129/01M34594B8JWJF47NSPNE6KP17/bin/fm-teardown.sh: line 1642: /private/var/folders/71/gpt_mxqn5b339ydgdzq6w4xw0000gn/T/fm-ledger-live.dO96VT/home/data/crew-dispatch/task-ledger.md: Permission denied
warning: task ledger row for ledger-rl could not be appended to /private/var/folders/71/gpt_mxqn5b339ydgdzq6w4xw0000gn/T/fm-ledger-live.dO96VT/home/data/crew-dispatch/task-ledger.md

## Final ledger
<!-- Machine-written by bin/fm-teardown.sh: one row per ship or scout cleanup, read from the task's durable records; "-" means the records did not carry the field. Do not hand-edit rows. -->

| task | date | kind | mode | repo | harness | model | effort | attempt | outcome | wall |
|---|---|---|---|---|---|---|---|---|---|---|
| ledger-ship | 2026-09-22 | ship | no-mistakes | project | sh | opus | high | 1 | https://github.com/example/repo/pull/77 - | 0h00m |
| ledger-forced | 2026-09-22 | ship | direct-PR | project | sh | default | default | 1 | discarded | 0h00m |
| ledger-refused | 2026-09-22 | ship | no-mistakes | project | sh | default | default | 1 | failed | 0h00m |
| ledger-scout | 2026-09-22 | scout | - | project | sh | sonnet | medium | 1 | data/ledger-scout/report.md | 0h00m |
