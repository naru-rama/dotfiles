#!/bin/bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# The nvim, Ghostty and Karabiner links point to ~/dotfiles
if [ "$DOTFILES" != "$HOME/dotfiles" ]; then
  echo "Clone this repo to ~/dotfiles and run it from there" >&2
  exit 1
fi

# On a Mac whose own config imports this repo, running this would drop that config
if [ -d "$HOME/dotfiles-private" ]; then
  echo "Run ~/dotfiles-private/install.sh on this Mac" >&2
  exit 1
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "Nix not found. Install Nix first" >&2
  exit 1
fi

# Flakes are not enabled on Macs without nix-darwin
export NIX_CONFIG="extra-experimental-features = nix-command flakes"

# With a fixed backup name, the second backup collides with the first one and fails
nix run --inputs-from "$DOTFILES" home-manager -- \
  switch -b "before-home-manager-$(date +%Y%m%d-%H%M%S)" --flake "$DOTFILES#default" --impure

# Run in $HOME so that mise doesn't pick up a repo's mise.toml
(cd "$HOME" && "$HOME/.nix-profile/bin/mise" install)
