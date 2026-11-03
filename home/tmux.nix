{ config, pkgs, ... }:
let
  # Nerd Font glyphs written directly in a file can get lost while editing, so write them as code points
  g = code: builtins.fromJSON ''"\u${code}"'';
  sepLeft = g "e0b0";
  sepRight = g "e0b2";

  # The blocks use the colors of the Neovim statusline (lualine with solarized-osaka); prefix turns them yellow
  # like command mode. The bar itself uses the terminal background, so it stands apart from the Neovim statusline
  aFg = "#001419";
  aBg = "#{?client_prefix,#f8ba00,#91c4ff}";
  bFg = "#001419";
  bBg = "#c6d6d7";
  cFg = "#b5cacd";
  cBg = "#0b1522";
  indexFg = "#91c4ff";

  openFile = pkgs.writeShellScript "tmux-open-file" (builtins.readFile ./tmux-open-file.sh);

  branch = pkgs.writeShellScript "tmux-branch" ''
    branch=$(${pkgs.git}/bin/git -C "$1" branch --show-current 2>/dev/null)
    [ -n "$branch" ] && printf '${g "e0a0"} %s ${g "e0b3"} ' "$branch"
  '';

  # Each window is a rounded tag separated by a gap; the current one is only a little brighter
  window =
    bg: index: fg:
    "#[fg=${bg},bg=${cBg}]${g "e0b6"}#[fg=${index},bg=${bg}]#I #[fg=${fg}]#W#{?@workmux_status, #{@workmux_status},}#[fg=${bg},bg=${cBg}]${g "e0b4"}";
in
{
  # Claude Code clamps colors to 256 inside tmux unless told that tmux passes truecolor (terminal-features below)
  home.sessionVariables.CLAUDE_CODE_TMUX_TRUECOLOR = "1";

  programs.tmux = {
    enable = true;
    prefix = "C-a";
    terminal = "tmux-256color";
    historyLimit = 10000;
    escapeTime = 0;
    baseIndex = 1;
    mouse = true;
    # Claude Code and Codex notify only while the terminal is unfocused
    focusEvents = true;
    extraConfig = ''
      set -g renumber-windows on

      set -as terminal-features 'xterm-ghostty:RGB'
      # Pass Claude Code and Codex notifications through to Ghostty
      set -g allow-passthrough on
      # For Shift+Enter newlines in Claude Code
      set -s extended-keys on
      set -as terminal-features 'xterm*:extkeys'

      bind r source-file ${config.xdg.configHome}/tmux/tmux.conf \; display "Reloaded tmux.conf"

      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Move the current window left or right in the list. Without -d, tmux keeps the old index selected
      bind -r < swap-window -d -t -1
      bind -r > swap-window -d -t +1

      bind t display-popup -E -d "#{pane_current_path}" -w 80% -h 70%
      # display-popup does not expand formats in its command, but run-shell does. The popup covers the current pane; -y is its bottom edge
      bind e run-shell -b "tmux display-popup -c '#{client_name}' -E -d '#{pane_current_path}' -w #{pane_width} -h #{pane_height} -x #{pane_left} -y #{e|+:#{pane_top},#{pane_height}} '${openFile} #{pane_id}'"

      bind L run-shell "workmux last-done"
      bind Tab run-shell "workmux last-agent"
      bind C-s display-popup -E -w 90% -h 80% "workmux dashboard"
      bind C-t run-shell "workmux sidebar"

      set -g status-position bottom
      set -g status-interval 5
      set -g status-style "fg=${cFg},bg=${cBg}"
      set -g status-left "#[fg=${aFg},bg=${aBg}] #h:#S #[fg=${aBg},bg=${cBg}]${sepLeft} "
      set -g status-left-length 40
      set -g status-right "#[fg=${bBg},bg=${cBg}]${sepRight}#[fg=${bFg},bg=${bBg}] #(${branch} '#{pane_current_path}')%m/%d #[fg=${aBg},bg=${bBg}]${sepRight}#[fg=${aFg},bg=${aBg}] %H:%M "
      set -g status-right-length 80
      set -g window-status-separator " "
      set -g window-status-format "${window "#1f3546" indexFg "#b5cacd"}"
      set -g window-status-current-format "${window "#2b5580" "#e6f0ff" "#ffffff"}"

      # Names for windows that workmux does not name: Claude Code's conversation title (its process is named after
      # its version, and the title is the host name until a conversation starts), the folder for shells, else the command
      set -g automatic-rename-format "#{?#{||:#{m/r:^[0-9.]+$,#{pane_current_command}},#{==:#{pane_current_command},claude}},#{?#{==:#{pane_title},#{host}},claude,#{=/24/...:pane_title}},#{?#{m/r:^(zsh|bash)$,#{pane_current_command}},#{b:pane_current_path},#{pane_current_command}}}"

      # tmux 3.8 draws popups (such as the workmux dashboard) on grey by default
      set -g popup-style "bg=default"
      set -g popup-border-style "fg=${cFg}"
    '';
  };
}
