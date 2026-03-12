# Contributing to git-worktree-manager

Thank you for your interest in contributing to git-worktree-manager! This guide will help you get started.

## How to Contribute

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/git-worktree-manager.git
   cd git-worktree-manager
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b fix/issue-name
   # or
   git checkout -b feature/new-feature
   ```
4. **Make your changes** to the `git-worktree-manager` script
5. **Test locally** using the script directly:
   ```bash
   ./git-worktree-manager --help
   # or use in a test repo
   cd /path/to/test/repo
   /path/to/your/clone/git-worktree-manager feature/test-branch
   ```
6. **Commit and push** your changes to your fork
7. **Open a pull request** to the `master` branch on the main repository
8. **Add a label** to your PR based on the type of change (see Versioning & Releases section)

## Versioning & Releases

This project uses **semantic versioning** (vMAJOR.MINOR.PATCH) with **fully automated releases via GitHub Actions**.

### How Releases Work

When a pull request is merged into `master`, the GitHub Actions workflow automatically:

1. Reads the labels on the PR
2. Calculates the next version number based on the label
3. Creates a git tag with the new version
4. Publishes a GitHub release with an auto-generated changelog

**You do not manually tag or release** — just merge the PR with the correct label, and the automation handles everything.

### Version Bump Rules

The label on your PR controls which version number components get incremented:

| Label | Type | Example | Use Case |
|-------|------|---------|----------|
| `patch` or no label | Patch bump | v1.0.0 → v1.0.1 | Bug fixes, small fixes, typos, minor improvements |
| `minor` | Minor bump | v1.0.0 → v1.1.0 | New features, new functionality, non-breaking changes |
| `major` | Major bump | v1.0.0 → v2.0.0 | Breaking changes, major rewrites, incompatible API changes |

### Choosing the Right Label

- **`patch`** — Use when you fix a bug, improve performance, or make other small changes that don't affect the public API or usage
  - Examples: fix Husky hooks in worktrees, improve error messages, add internal optimizations
- **`minor`** — Use when you add a new feature or capability that is backward-compatible
  - Examples: add support for a new project type, add a new flag, add symlink mode
- **`major`** — Use when you make a breaking change that requires users to update their workflow or change how they use the tool
  - Examples: remove a flag, change the default behavior in a way that breaks existing scripts, rename commands
- **No label** — Defaults to `patch` bump

### Example PR Workflow

```bash
# Create a PR that fixes a bug
git checkout -b fix/husky-hooks
# ... make changes ...
git commit -m "Fix Husky git hooks not found in worktrees"
git push origin fix/husky-hooks

# Open PR on GitHub
# GitHub will show you a dialog to add labels
# Click "patch" (or leave empty) since this is a bug fix
# → v1.0.0 becomes v1.0.1 when merged
```

```bash
# Create a PR that adds a new feature
git checkout -b feature/copy-ignore-file
# ... make changes ...
git commit -m "Add support for .gitignore-worktree files"
git push origin feature/copy-ignore-file

# Open PR on GitHub
# Click "minor" label
# → v1.0.0 becomes v1.1.0 when merged
```

### User Updates

Users of the tool can update to the latest version using:

```bash
git-worktree-manager --update
```

## Development Setup

### Prerequisites

- `bash` 4+
- `git`
- `python3` (for testing the registry functionality)

### Testing Your Changes Locally

1. Make changes to the `git-worktree-manager` script
2. Test in a real git repository:
   ```bash
   cd /path/to/test/repo
   /path/to/your/clone/git-worktree-manager feature/test-branch
   ```
3. Use dry-run mode to preview changes without executing:
   ```bash
   /path/to/your/clone/git-worktree-manager --dry-run feature/test-branch
   ```
4. Test the registry functionality:
   ```bash
   /path/to/your/clone/git-worktree-manager --list
   /path/to/your/clone/git-worktree-manager -r test-id
   ```

### Common Test Scenarios

- Create a worktree in a Node.js project and verify `node_modules` are copied
- Create a worktree in a Python project and verify the virtualenv paths are fixed
- Create a worktree in a Go project and verify `vendor` is copied
- Test with a branch name containing `/` (e.g., `feature/my-feature`)
- Test the `--symlink` flag to verify symlinks work
- Test removal with `--list` and `--remove` commands

## Code Style

- Use `bash` idioms and built-in utilities where possible
- Keep functions focused and single-purpose
- Add comments for non-obvious logic
- Test edge cases (branch names with special characters, paths with spaces, etc.)
- Ensure the script works on both macOS and Linux

## Questions?

Feel free to open an issue on GitHub if you have questions or need clarification on anything in this guide.
