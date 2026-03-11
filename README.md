# git-worktree-manager

Create fully functional git worktrees with all runtime dependencies copied over — so the new worktree is immediately ready to run.

Standard `git worktree add` only checks out the source code. It doesn't copy `node_modules`, `.env` files, virtual environments, Pods, or any other gitignored files your project needs to actually run. This tool does.

## Features

- Auto-detects project type and copies the right dependencies
- Assigns a unique ID to each worktree for easy management
- Supports branch names with `/` (e.g. `fix/my-bug`)
- Handles monorepo workspaces (npm/yarn/pnpm)
- Optional symlink mode to save disk space
- Built-in registry to list and remove worktrees by ID

## Supported Project Types

| Type | Detected By | What Gets Copied |
|------|------------|------------------|
| **Node.js** | `package.json` | `node_modules`, workspace `node_modules`, `.next`, `.nuxt`, `.turbo`, `dist`, `build` |
| **React / Vue / Angular** | `react`/`next`/`vue`/`angular` in `package.json` | Same as Node.js |
| **Python** | `requirements.txt`, `pyproject.toml`, `Pipfile`, `setup.py` | `venv`/`.venv` (with path fixup), `.python-version` |
| **Go** | `go.mod` | `vendor`, `.air.toml`, `tmp` (build cache) |
| **iOS / Xcode** | `Podfile` | `Pods`, `.build`, `.swiftpm`, `Carthage`, `.xcworkspace`, `GoogleService-Info.plist`, `.xcconfig` |

All project types also get:
- Environment files: `.env`, `.env.local`, `.env.development`, `.env.test`, `.env.production`, `.env.staging` (and their `.local` variants)
- Common config: `.editorconfig`, `.tool-versions`, `.nvmrc`, `.node-version`, `.ruby-version`, `.mise.toml`, `docker-compose.override.yml`

Multiple project types can be detected simultaneously (e.g. a Node.js + React project).

## Installation

### Requirements

- `git`
- `python3` (for the worktree registry — pre-installed on macOS and most Linux distros)
- `bash` 4+

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

## Commands Reference

```
git-worktree-manager [options] <branch> [worktree-path]
git-worktree-manager --remove <id|branch|path>
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

## How It Works

1. **Creates a git worktree** using `git worktree add` for the given branch
2. **Detects the project type** by looking for marker files (`package.json`, `go.mod`, `Podfile`, etc.)
3. **Copies runtime dependencies** that are typically gitignored but required to run the project
4. **Registers the worktree** in a JSON registry at `~/.config/git-worktree-manager/registry.json` with a unique 6-character ID
5. For **Python projects**, it fixes the virtualenv paths (`pyvenv.cfg` and `activate` scripts) to point to the new worktree location

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
