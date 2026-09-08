## Agent skills

### Issue tracker

Issues live in GitHub Issues on [generalChang/solvoca](https://github.com/generalChang/solvoca). See `docs/agents/issue-tracker.md`.

### Triage labels

Canonical roles map 1:1 to tracker labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

single-context. See `docs/agents/domain.md`.

### Implementing a ticket

**One GitHub issue → one pull request.** Do not land ticket work directly on `main`.

1. **Frontier** — Pick an open, unblocked child ticket (no open `blocked_by` dependencies). Read the full issue before coding. See `docs/agents/issue-tracker.md` for `gh` commands.
2. **Branch** — From up-to-date `main`, create `issue/<number>-<short-slug>` (e.g. `issue/5-day-complete`).
3. **Implement** — Use TDD at the agreed seam (Study for Solvoca v1). Run the relevant tests before opening the PR.
4. **Pull request** — Push the branch and open a PR against `main`. The PR body must include `Closes #<number>` so the issue auto-closes on merge. Title should name the ticket (e.g. `Day complete, next day, Streak to Mastered (#5)`).
5. **Do not** — Commit ticket work on `main`; bundle multiple issues in one PR; close the ticket by hand when the PR will auto-close on merge.

The human merges after review. Do not close parent spec issues (e.g. #1) as part of ticket work.
