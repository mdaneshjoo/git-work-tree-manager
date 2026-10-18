---
name: git-worktree-manager
description: Create, list, and remove git worktrees that are immediately runnable — node_modules, .env files, virtualenvs, vendor, Pods, and Husky hooks are copied in (monorepo packages included). Use whenever a task needs a separate worktree or branch checkout (parallel work, isolated agents, reviewing a branch without touching the current checkout), instead of `git worktree add`.
---

# git-worktree-manager

`git worktree add` only checks out tracked files, so the new worktree can't run (no `node_modules`, no `.env`). `git-worktree-manager` creates the worktree **and** copies the untracked runtime files at any depth (`apps/*/node_modules`, `apps/api/.env`, nested `.venv`, …).

## Rules

- **Always** use `git-worktree-manager` instead of bare `git worktree add`.
- **Always** pass `--json` and parse stdout. Progress and warnings go to stderr.
- **Never** run `--remove` without the user's OK: it **force-deletes the branch** (`git branch -D`), so unmerged commits are lost. Pass `--yes` only after the user agreed.
- Run commands from inside the repo (any subdirectory works).

## Commands

| Goal | Command |
|------|---------|
| Create (new branch from HEAD) | `git-worktree-manager --json <branch>` |
| Create from a base branch | `git-worktree-manager --json --base main <branch>` |
| Create at a specific path | `git-worktree-manager --json <branch> <path>` |
| Preview, no changes | `git-worktree-manager --json --dry-run <branch>` |
| List (this repo / all repos) | `git-worktree-manager --json --list` / `--list --all` |
| Remove (after user confirmed) | `git-worktree-manager --json --yes --remove <id\|branch\|path>` |
| Version | `git-worktree-manager --json --version` |

Creating is **idempotent**: if the branch already has a worktree, the same `id` and `path` come back with `"created": false`.

## JSON output

Create:

```json
{
  "id": "a3f7x2",
  "repo": "/abs/path/my-project",
  "branch": "feature/login",
  "path": "/abs/path/my-project-feature-login",
  "created": true,
  "dry_run": false,
  "copied": [{"mode": "copy", "path": "apps/api/.env"}, {"mode": "copy", "path": "node_modules"}],
  "skipped": [{"reason": "exists", "path": "dist"}]
}
```

- Work in `path` afterwards (`cd "<path>"`). All paths are absolute.
- `--list` prints an array of `{id, repo, branch, path, created_at}`.
- `--remove` prints `{id, repo, branch, path, removed, branch_deleted}`.
- On failure: `{"error": "<message>", "exit_code": <n>}`.

## Exit codes

| Code | Meaning | What to do |
|------|---------|------------|
| 0 | Success | Use the JSON |
| 1 | Error (not a git repo, git failed, branch has a worktree at another path) | Read `error`, fix, retry |
| 2 | Invalid usage | Fix the flags (`--help`) |
| 3 | Worktree not found (`--remove`) | `--list` to find the right id |
| 4 | Confirmation required (`--remove` without `--yes`) | Ask the user, then add `--yes` |

## Not installed?

`command -v git-worktree-manager` fails → install it:

```bash
curl -fsSL https://raw.githubusercontent.com/mdaneshjoo/git-work-tree-manager/master/install.sh | bash
export PATH="$HOME/bin:$PATH"
```
