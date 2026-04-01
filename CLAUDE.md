# Claude Code Rules

## Contributing Workflow

Always follow the contribution guidelines in `CONTRIBUTING.md` when making changes:

1. **Branch from `master`** — Create a feature (`feature/`) or fix (`fix/`) branch from `master`
2. **Make changes** to the `git-worktree-manager` script
3. **Test locally** — Use `--dry-run` and test in a real repo before committing
4. **Commit and push** the feature/fix branch
5. **Create a PR** targeting `master` with the appropriate label:
   - `patch` (or no label) — bug fixes, small improvements
   - `minor` — new features, new flags, non-breaking changes
   - `major` — breaking changes

Merging to `master` triggers an automatic release via GitHub Actions. Never manually tag or release.
