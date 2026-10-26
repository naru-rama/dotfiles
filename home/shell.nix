{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Nerd Font glyphs written directly in a file can get lost while editing, so write them as code points
  g = code: builtins.fromJSON ''"\u${code}"'';

  bg = "238";
  sepLeft = "[${g "e0b1"}](fg:246 bg:${bg})";
  sepRight = "[${g "e0b3"}](fg:246 bg:${bg})";
in
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch = {
      enable = true;
      searchUpKey = [
        "^[[A"
        "^[OA"
      ];
      searchDownKey = [
        "^[[B"
        "^[OB"
      ];
    };

    history = {
      path = "${config.home.homeDirectory}/.zsh_history";
      size = 100000;
      save = 100000;
      share = true;
      extended = true;
      ignoreAllDups = true;
      ignoreSpace = true;
    };

    initContent = lib.mkMerge [
      # fzf-tab must load after compinit (570) and before zsh-autosuggestions (700) and syntax-highlighting (1200)
      (lib.mkOrder 600 ''
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      '')
      # trash doesn't accept options like -rf, so drop them.
      # Claude Code picks up this config, but its sandbox can't write to ~/.Trash and rm would fail there
      ''
        if [[ -z $CLAUDECODE ]]; then
          rm() {
            local args=() a
            for a in "$@"; do
              [[ $a == -* ]] || args+=("$a")
            done
            trash "''${args[@]}"
          }
        fi
      ''
    ];

    shellAliases = {
      gd = ''(ref=$(git symbolic-ref --short refs/remotes/origin/HEAD) && git switch "''${ref#origin/}")'';
      vim = "nvim";
      ls = "ls -p -G";
      la = "ls -A";
      ll = "eza -l -g --icons=auto";
      lla = "ll -a";
      wa = "workmux add -A -b -p";
      we = "workmux add -A -e";
      wo = "workmux open -c";
      wr = "workmux remove";
    };
  };

  programs.fzf.enable = true;
  programs.zoxide.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;

      format = lib.concatStrings [
        "$os"
        # Modules that import this one add their own env_var.<NAME>
        "$env_var"
        "$directory"
        "$git_branch"
        "$git_status"
        "[${g "e0b0"}](fg:${bg})"
        "$fill"
        "[${g "e0b2"}](fg:${bg})"
        "$status"
        "$cmd_duration"
        "$jobs"
        "$kubernetes"
        "$terraform"
        "$aws"
        "$time"
        "$line_break"
        "$character"
      ];

      fill.symbol = " ";

      os = {
        disabled = false;
        format = "[ $symbol ](fg:255 bg:${bg})";
        symbols.Macos = g "f179";
      };

      directory = {
        style = "fg:31 bg:${bg}";
        before_repo_root_style = "fg:103 bg:${bg}";
        repo_root_style = "bold fg:39 bg:${bg}";
        read_only = " ${g "f023"}";
        read_only_style = "fg:160 bg:${bg}";
        format = "${sepLeft}[ ${g "f07c"} $path ]($style)[$read_only]($read_only_style)";
        repo_root_format = "${sepLeft}[ ${g "f07c"} $before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path ]($style)[$read_only]($read_only_style)";
      };

      git_branch = {
        symbol = "${g "f126"} ";
        style = "fg:76 bg:${bg}";
        format = "${sepLeft}[ $symbol$branch ]($style)";
      };

      git_status = {
        style = "fg:178 bg:${bg}";
        format = "([$all_status$ahead_behind ]($style))";
      };

      status = {
        disabled = false;
        symbol = "✘ ";
        style = "fg:160 bg:${bg}";
        format = "[ $symbol$status ]($style)${sepRight}";
      };

      cmd_duration = {
        min_time = 3000;
        style = "fg:248 bg:${bg}";
        format = "[ $duration ${g "f252"} ]($style)${sepRight}";
      };

      jobs = {
        symbol = "${g "f013"} ";
        style = "fg:70 bg:${bg}";
        format = "[ $symbol$number ]($style)${sepRight}";
      };

      kubernetes = {
        disabled = false;
        symbol = "☸ ";
        style = "fg:134 bg:${bg}";
        format = "[ $symbol$context( \\($namespace\\)) ]($style)${sepRight}";
        detect_env_vars = [ "KUBECONFIG" ];
        detect_files = [
          "kustomization.yaml"
          "Chart.yaml"
          "helmfile.yaml"
        ];
      };

      terraform = {
        symbol = "󱁢 ";
        style = "fg:38 bg:${bg}";
        format = "[ $symbol$workspace ]($style)${sepRight}";
      };

      aws = {
        symbol = "${g "f270"} ";
        style = "fg:208 bg:${bg}";
        format = "[ $symbol($profile )(\\($region\\) )]($style)${sepRight}";
      };

      time = {
        disabled = false;
        time_format = "%H:%M:%S";
        style = "fg:66 bg:${bg}";
        format = "[ $time ${g "f017"} ]($style)";
      };

      character = {
        success_symbol = "[❯](bold fg:76)";
        error_symbol = "[❯](bold fg:196)";
      };
    };
  };
}
