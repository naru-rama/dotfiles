{ config, pkgs, ... }:
let
  # Nerd Font glyphs written directly in a file can get lost while editing, so write them as code points
  g = code: builtins.fromJSON ''"\u${code}"'';
  sepLeft = g "e0b0";
  sepRight = g "e0b2";

  # The colors of the Neovim statusline (lualine with solarized-osaka); prefix turns it yellow like command mode
  aFg = "#001419";
  aBg = "#{?client_prefix,#f8ba00,#91c4ff}";
  bFg = "#001419";
  bBg = "#c6d6d7";
  cFg = "#b5cacd";
  cBg = "#002c38";

  branch = pkgs.writeShellScript "tmux-branch" ''
    branch=$(${pkgs.git}/bin/git -C "$1" branch --show-current 2>/dev/null)
    [ -n "$branch" ] && printf '${g "e0a0"} %s ${g "e0b3"} ' "$branch"
  '';

  window = "#I #W#{?@workmux_status, #{@workmux_status},}";
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

      bind L run-shell "workmux last-done"
      bind Tab run-shell "workmux last-agent"
      bind C-s display-popup -E -w 90% -h 80% "workmux dashboard"
      bind C-t run-shell "workmux sidebar"

      set -g status-position bottom
      set -g status-interval 5
      set -g status-style "fg=${cFg},bg=${cBg}"
      set -g status-left "#[fg=${aFg},bg=${aBg}] #S #[fg=${aBg},bg=${cBg}]${sepLeft} "
      set -g status-left-length 40
      set -g status-right "#[fg=${bBg},bg=${cBg}]${sepRight}#[fg=${bFg},bg=${bBg}] #(${branch} '#{pane_current_path}')%m/%d #[fg=${aBg},bg=${bBg}]${sepRight}#[fg=${aFg},bg=${aBg}] %H:%M "
      set -g status-right-length 80
      set -g window-status-separator ""
      set -g window-status-format " ${window} "
      set -g window-status-current-format "#[fg=${cBg},bg=${bBg}]${sepLeft}#[fg=${bFg}] ${window} #[fg=${bBg},bg=${cBg}]${sepLeft}"

      # tmux 3.8 draws popups (such as the workmux dashboard) on grey by default
      set -g popup-style "bg=default"
      set -g popup-border-style "fg=${cFg}"
    '';
  };
}
