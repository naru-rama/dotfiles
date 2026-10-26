# dotfiles

Shared settings for my Macs. The shell, tmux and CLI tools are managed with home-manager (per user),
and the Neovim, Ghostty and Karabiner settings are plain files linked into place.

## Layout

| Path | Contents |
|---|---|
| `flake.nix` | Entry point: the shared module (`homeModules.default`) and a config for Macs that use only this repo (`homeConfigurations.default`) |
| `home/default.nix` | CLI tools, mise, Docker (Colima), git and macOS settings |
| `home/shell.nix` | zsh and the prompt (Starship) |
| `home/tmux.nix` | tmux |
| `nvim/` | Neovim (`~/.config/nvim` links here; plugins come from lazy.nvim, pinned in `lazy-lock.json`) |
| `ghostty/` | Ghostty config and theme (`~/.config/ghostty` links here; press `Cmd+Shift+,` in Ghostty to reload) |
| `karabiner/karabiner.json` | Karabiner-Elements (`~/.config/karabiner` links here) |
| `workmux/config.yaml` | workmux (`~/.config/workmux/config.yaml` links here; see below) |
| `install.sh` | For Macs that use only this repo: applies the home-manager config and installs the mise tools |

Other flakes can import `homeModules.default`.
The links point to `~/dotfiles`, so clone this repo there either way.

## Setup on a Mac that uses only this repo

1. Install Nix

   ```sh
   sh <(curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install) --daemon
   ```

2. Open a new terminal and run

   ```sh
   git clone https://github.com/naru-rama/dotfiles.git ~/dotfiles
   ~/dotfiles/install.sh
   ```

3. Install Ghostty and Karabiner-Elements: `brew install --cask ghostty karabiner-elements`
4. Open Karabiner-Elements and allow its driver and Input Monitoring
5. Put your git name and email in `~/.gitconfig`. The `~/.config/git/config` written by home-manager is read-only,
   so create `~/.gitconfig` first (when it exists, `git config --global` writes there)

   ```sh
   touch ~/.gitconfig
   git config --global user.name "<name>"
   git config --global user.email "<email>"
   ```

6. Log out and back in to apply the Dock, key repeat and other macOS settings

## Updating

```sh
git -C ~/dotfiles pull --ff-only
~/dotfiles/install.sh
```

Then run `:Lazy restore` in nvim to put the plugins back on the versions in `lazy-lock.json`.

### Macs that only pull

Some files are rewritten by the apps themselves, and once they change, the next `git pull` stops.

| File | Rewritten when | What to do |
|---|---|---|
| `nvim/lazy-lock.json` | `:Lazy update` updates the plugins | Don't update; use `:Lazy restore` |
| `karabiner/karabiner.json` | settings change in the Karabiner GUI | Don't change them |
| `ghostty/config` | edited by hand | Don't edit it |
| `flake.lock` | `nix flake update` runs | Don't run it |

If one has changed, restore it with `git -C ~/dotfiles checkout -- .` and pull again.

## Parallel tasks with workmux

[workmux](https://github.com/raine/workmux) gives each task its own git worktree, branch and tmux window,
with Neovim on the left (opened on the file tree of the worktree) and Claude Code on the right (`workmux/config.yaml`).

```sh
cd ~/workspace/myapp
tmux new -A -s myapp                          # one tmux session per repo
workmux add fix-auth -p "Fix the login bug"   # worktree, branch and window for the task
workmux remove fix-auth                       # after the PR is merged (`workmux merge` merges locally instead)
```

Shell aliases: `wa "prompt"` (`workmux add -A -p`, which names the branch from the prompt),
`we` (the same, with the prompt written in `$EDITOR`), `wo name` (`workmux open -c`, resumes the last conversation)
and `wr name` (`workmux remove`).

| Key (the prefix is `Ctrl+A`) | Action |
|---|---|
| `prefix L` | Go to an agent that finished or is waiting for input |
| `prefix Tab` | Toggle between the two most recent agents |
| `prefix Ctrl+S` | Dashboard in a popup (status, diffs, input to agents) |
| `prefix Ctrl+T` | Toggle the sidebar |

- Window names show the agent status (🤖 working, 💬 waiting, ✅ done) through Claude Code hooks.
  The first `workmux add` offers to install the hooks and skills into `~/.claude`: answer `n` if your Claude Code
  settings already have them, otherwise accept (or run `workmux setup` later)
- Worktrees go next to the repo (`<repo>__worktrees/`), so per-directory settings such as mise's apply to them too
- Claude Code asks whether to trust a new worktree unless the main checkout is already trusted
- `workmux claude prune` removes entries for deleted worktrees from `~/.claude.json`

## Notes

- Files written by home-manager (`~/.config/git/config`, `~/.zshrc`, ...) are read-only; edit `home/` instead
- Removing a line from the macOS settings (`targets.darwin.defaults`) doesn't revert it; change the value instead
- In a git checkout, Nix doesn't see new files until they are `git add`ed
- For the versions of terraform, kubectl, kustomize and so on, put a `mise.toml` in the repo.
  The defaults for repos that don't pin them are in `programs.mise` in `home/default.nix`
- Ports in the Colima VM (`docker run -p`, the k3s API) listen only on the Mac's localhost and can't be reached from the LAN
  (Colima exposes them to the LAN by default; the lima override in `home/default.nix` changes that. Restart the VM after changing it)
- After changing the Colima settings (CPU, memory, ...), run `colima stop` after `install.sh`, then
  `launchctl kickstart -k gui/$(id -u)/org.nix-community.home.colima-default` to start it with the new settings
