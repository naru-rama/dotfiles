# Lists the files mentioned in a tmux pane and opens the chosen one in Neovim.
# Usage: tmux-open-file <pane id>
set -u

screen=$(tmux capture-pane -p -J -S -300 -t "$1")

tokens() {
  grep -aoE '[A-Za-z0-9_.~/+@-]*[/.][A-Za-z0-9_.~/+@-]+'
}

# Claude Code breaks long paths with real line breaks, which capture-pane -J cannot rejoin
joined=$(printf '%s\n' "$screen" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' | tr -d '\n')

# Joining can also glue the next line's text onto a path, so shorten each token until it names a file
existing() {
  while IFS= read -r path; do
    path=${path/#\~/$HOME}
    while [[ ! -f $path && ($path == */* || $path == *.*) ]]; do
      path=${path%?}
    done
    if [[ -f $path && ($path == */* || $path == *.*) ]]; then
      path=${path#"$PWD"/}
      printf '%s\n' "${path#./}"
    fi
  done
}

# Newest first: the joined text comes last, so after reversing it ranks above the single lines
files=$({
  printf '%s\n' "$screen" | tokens
  printf '%s\n' "$joined" | tokens
} | existing | tail -r | awk '!seen[$0]++')

if [[ -z $files ]]; then
  tmux display-message "No files found on screen"
  exit 0
fi

# Only the changed files, if any were mentioned: uncommitted ones and those committed on this branch
changed=$({
  base=$(git rev-parse -q --verify origin/HEAD || git rev-parse -q --verify origin/main)
  git -c core.quotepath=off diff --name-only --relative HEAD
  git -c core.quotepath=off diff --name-only --relative "$base...HEAD"
  git -c core.quotepath=off ls-files --others --exclude-standard
} 2>/dev/null)
mentioned=$(printf '%s\n' "$files" | grep -Fx -e "$changed")
if [[ -n $mentioned ]]; then
  files=$mentioned
fi

file=$(printf '%s\n' "$files" | fzf --select-1 --exit-0 --keep-right --prompt 'open> ') || exit 0
exec nvim "$file"
