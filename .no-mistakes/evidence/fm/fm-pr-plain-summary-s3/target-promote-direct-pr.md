Your scout task has been promoted to a ship task, mode=direct-PR. Your window, worktree, and context stay as they are; only the contract below changes.

# Task
## Captain's intent
Make worker PRs explain the ask in plain language.

## Firstmate spec
1. **Verify isolation before anything else.** Run `pwd -P` and `git rev-parse --show-toplevel`; both must resolve to the disposable task worktree you were launched in, such as a treehouse pool path or an Orca-managed worktree, not the primary checkout firstmate operates from. If either does not resolve to the worktree you were launched in, stop and escalate to firstmate.
2. Inventory this worktree's scratch state with `git status` and `git log` before changing anything.
3. Return to a clean default-branch base, then create your branch: `git checkout -b fm/promote-direct-pr`.
4. Carry over only the intended fix changes. Leave scratch commits, debug edits, and experiment files behind.
5. If you reproduced a bug, turn that reproduction into a regression test.
6. These ship instructions supersede the scout delivery rules and report-based Definition of done. Everything else in your original instructions carries over unchanged: the status protocol; the instruction inbox and its acknowledgement; the escalation rules, including ask-user; and every safety rule.

7. Treat the scout-time Firstmate spec and any unmarked legacy `# Task` text as investigation context, not captain intent or ship-time instructions.

# Definition of done
Delivery contract: mode=direct-PR
This task ships **direct-PR**: you raise the PR yourself, without the no-mistakes pipeline.
The task is complete only when committed on your branch.
When it is implemented and committed, push your branch and open a PR with `gh-axi`, then append `done: PR {url}` to the status file and stop.
Do NOT run /no-mistakes. The configured merge authority decides whether to merge the PR; firstmate relays the outcome.

# PR body
Write for the captain first: plain language before evidence, in this section order:
- `## Intent` - open with a plain-language paragraph of the captain's ask and why it matters to him, then explicit scope (in and out) and acceptance criteria.
- `## What Changed` - one bullet per changed file saying what changed there.
- `## Choices made where the spec was silent` - every choice the spec did not settle, least-confident first.
- `## Risk Assessment` - a severity line with blast-radius reasoning and what was verified unchanged.
- `## Testing` - reproduce-first evidence on the base commit and after the fix, then lint and test evidence.
The no-mistakes Pipeline section and attestation stamp are tool-owned: never hand-write or edit them.
