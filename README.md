# git-worktree-manager

Create fully functional git worktrees with all runtime dependencies copied over — so the new worktree is immediately ready to run.

Standard `git worktree add` only checks out the source code. It doesn't copy `node_modules`, `.env` files, virtual environments, Pods, or any other gitignored files your project needs to actually run. This tool does.

## Features

- Finds runtime dependencies anywhere in the repo and copies them
- Assigns a unique ID to each worktree for easy management
- Supports branch names with `/` (e.g. `fix/my-bug`)
- Monorepo aware: copies `apps/*/node_modules`, `apps/api/.env`, nested virtualenvs, etc. (npm/yarn/pnpm/Nx/Turbo/Lerna)
- Optional symlink mode to save disk space
- Built-in registry to list and remove worktrees by ID
- AI-agent friendly: `--json`, no prompts with `--yes`, stable exit codes, and an [agent skill](#install-with-an-ai-agent)

## What Gets Copied

Every untracked or gitignored path in the repo is checked by name, **at any depth**. Matches are copied to the same relative path in the worktree, so monorepo packages are covered without any config.

| Type | What Gets Copied |
|------|------------------|
| **Node.js / React** | `node_modules`; `.next`, `.nuxt`, `.turbo`, `dist`, `build` (when next to a `package.json`) |
| **Python** | Any virtualenv (dir with `bin/activate`, with path fixup), `.python-version` |
| **Go** | `vendor`, `.air.toml`, `tmp` (when next to `.air.toml`) |
| **iOS / Xcode** | `Pods`, `.build`, `.swiftpm`, `Carthage`, `*.xcworkspace`, `*.xcconfig`, `GoogleService-Info.plist`, `firebase.json` |
| **Husky** | `.husky/_` (gitignored helper dir that `core.hooksPath` points at) |
| **All** | `.env`, `.env.*`, `.editorconfig`, `.tool-versions`, `.nvmrc`, `.node-version`, `.ruby-version`, `.mise.toml`, `.mise.local.toml`, `docker-compose.override.yml`, `.docker-env` |

Tracked files are never copied (they are already in the checkout). Paths that already exist in the worktree are skipped.

Example monorepo:

```
apps/api/.env               → copied
apps/api/node_modules/      → copied
apps/web/.env.local         → copied
apps/web/.next/             → copied
packages/ui/node_modules/   → copied
services/worker/.venv/      → copied, paths fixed
```

## Install with an AI Agent

Paste this prompt into your AI coding agent (Claude Code, Cursor, Codex, ...). It installs the CLI and the agent skill:

```text
Install git-worktree-manager and its agent skill for me:

1. Install the CLI:
   curl -fsSL https://raw.githubusercontent.com/mdaneshjoo/git-work-tree-manager/master/install.sh | bash
2. If `command -v git-worktree-manager` fails, run `export PATH="$HOME/bin:$PATH"`.
   Then run `git-worktree-manager --version --json` and show me the version.
3. Install the agent skill globally:
   npx skills add mdaneshjoo/git-work-tree-manager --skill git-worktree-manager -g -y
4. Tell me where the CLI and the skill were installed.

From now on, create git worktrees with git-worktree-manager (using --json), never with bare `git worktree add`.
```

The skill ([skills/git-worktree-manager/SKILL.md](skills/git-worktree-manager/SKILL.md)) teaches the agent the commands, the JSON output, and the exit codes. It also tells the agent to ask you before `--remove`, because removing deletes the branch.

## Installation

### Requirements

- `git`
- `python3` (for the worktree registry — pre-installed on macOS and most Linux distros)
- `bash` 3.2+ (the macOS default works)

### One-liner

```bash
curl -fsSL https://raw.githubusercontent.com/mdaneshjoo/git-work-tree-manager/master/install.sh | bash
```

### From source

```bash
git clone https://github.com/mdaneshjoo/git-work-tree-manager.git
cd git-worktree-manager
./install.sh
```

### Manual

```bash
cp git-worktree-manager ~/bin/
chmod +x ~/bin/git-worktree-manager

# Make sure ~/bin is in your PATH
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Custom install directory

```bash
INSTALL_DIR=/usr/local/bin ./install.sh
```

## Usage

### Create a worktree

```bash
cd your-project
git-worktree-manager <branch> [worktree-path]
```

The branch is created from current HEAD if it doesn't exist. The worktree path defaults to `../<project>-<branch>` (slashes in branch names are replaced with dashes).

**Examples:**

```bash
# Create worktree for a new feature branch
git-worktree-manager feature/new-dashboard

# Worktree is created at ../your-project-feature-new-dashboard/
# with node_modules, .env, etc. all copied over

# Specify a custom path
git-worktree-manager hotfix/login ~/worktrees/login-fix

# Use an existing branch
git-worktree-manager develop
```

### List worktrees

```bash
# List worktrees for the current repo
git-worktree-manager -l
git-worktree-manager --list

# List worktrees across all repos
git-worktree-manager --all -l
```

Output:

```
[i] Worktrees for my-project:

  ID       Branch                    Created              Path
  ──       ──────                    ───────              ────
  a3f7x2   feature/new-dashboard    2026-03-11 14:30     /Users/you/projects/my-project-feature-new-dashboard
  k9m2p1   hotfix/login             2026-03-10 09:15     /Users/you/worktrees/login-fix
```

### Remove a worktree

```bash
# Remove by ID (shown when created and in --list output)
git-worktree-manager -r a3f7x2
git-worktree-manager --remove a3f7x2

# Remove by branch name
git-worktree-manager -r feature/new-dashboard

# Remove by path
git-worktree-manager -r /Users/you/projects/my-project-feature-new-dashboard
```

Removal will:
1. Ask for confirmation
2. Remove the worktree directory
3. Delete the git branch
4. Remove the entry from the registry

### Dry run

Preview what would be copied without making any changes:

```bash
git-worktree-manager -n feature/test
git-worktree-manager --dry-run feature/test
```

### Symlink mode

Use symlinks instead of copies for large directories (`node_modules`, `vendor`, `Pods`). Saves disk space but changes in one worktree's dependencies affect the other:

```bash
git-worktree-manager --symlink feature/experiment
```

### Scripts and AI agents

| Feature | Behavior |
|---------|----------|
| `--json` | Results as JSON on stdout; progress messages suppressed |
| stdout / stderr | stdout has only results (path, list, JSON); messages go to stderr |
| No prompts | `--remove` needs `--yes` when there is no terminal (exits `4` instead of waiting) |
| Idempotent | Creating a worktree for a branch that already has one returns the existing one (`"created": false`) |
| Parallel safe | Registry writes are locked, so several agents can create worktrees at once |
| Colors | Only on a terminal; disabled by `NO_COLOR` |

```bash
cd "$(git-worktree-manager feature/x)"           # stdout is the worktree path
git-worktree-manager --json feature/x | jq .path
git-worktree-manager --json --yes -r feature/x
```

Create output:

```json
{
  "id": "a3f7x2",
  "repo": "/Users/you/projects/my-project",
  "branch": "feature/x",
  "path": "/Users/you/projects/my-project-feature-x",
  "created": true,
  "dry_run": false,
  "copied": [{"mode": "copy", "path": "apps/api/.env"}, {"mode": "copy", "path": "node_modules"}],
  "skipped": []
}
```

Errors (with `--json`): `{"error": "<message>", "exit_code": <n>}`

| Exit code | Meaning |
|-----------|---------|
| `0` | Success |
| `1` | Error (not a git repo, git failed, branch already has a worktree at another path) |
| `2` | Invalid usage (unknown option, missing branch) |
| `3` | Worktree not found (`--remove`) |
| `4` | Confirmation required or declined (`--remove`) |

## Commands Reference

```
git-worktree-manager [options] <branch> [worktree-path]
git-worktree-manager --remove <id|branch|path> [--yes]
git-worktree-manager --list [--all]
```

| Flag | Short | Description |
|------|-------|-------------|
| `--help` | `-h` | Show help message |
| `--dry-run` | `-n` | Preview what would happen without making changes |
| `--symlink` | | Symlink large dirs instead of copying |
| `--remove` | `-r` | Remove a worktree by ID, branch, or path |
| `--list` | `-l` | List registered worktrees for the current repo |
| `--all` | | Used with `--list` to show worktrees from all repos |
| `--yes` | `-y` | Skip the `--remove` confirmation (required without a terminal) |
| `--json` | | Print results as JSON on stdout |
| `--base` | `-b` | Base branch for a new branch (default: current HEAD) |
| `--update` | | Update to the latest release |
| `--version` | `-v` | Show the installed version |

## How It Works

1. **Creates a git worktree** using `git worktree add` for the given branch
2. **Lists untracked and gitignored paths** with `git ls-files --others --ignored --directory` (ignored dirs like `node_modules` are listed once, not walked)
3. **Copies runtime dependencies** matched by name at any depth (see [What Gets Copied](#what-gets-copied))
4. **Registers the worktree** in a JSON registry at `~/.config/git-worktree-manager/registry.json` with a unique 6-character ID
5. For **Python projects**, it fixes the virtualenv paths (`pyvenv.cfg` and `activate` scripts) to point to the new worktree location
6. For **Husky**, an absolute `core.hooksPath` inside the repo is overridden for the worktree only (`git config --worktree`), so the main repo's hooks are never changed

### Registry

The registry is a simple JSON file stored at `~/.config/git-worktree-manager/registry.json`. It tracks:

- **id** — unique 6-character alphanumeric identifier
- **repo** — absolute path to the source repository
- **branch** — branch name
- **path** — absolute path to the worktree
- **created_at** — creation timestamp

The registry is managed using `python3` for portable JSON handling.

## Uninstall

```bash
rm ~/bin/git-worktree-manager
rm -rf ~/.config/git-worktree-manager
```

Remove the `export PATH="$HOME/bin:$PATH"` line from your shell config if you no longer need it.

## License

MIT
