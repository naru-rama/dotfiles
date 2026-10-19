{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./shell.nix
    ./tmux.nix
  ];

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "acli" ];

  home.packages = with pkgs; [
    awscli2
    aws-vault
    gh
    acli
    google-cloud-sdk
    docker
    neovim
    pre-commit
    ripgrep
    fd
    jq
    eza
    # nvim language servers (gopls and terraform-ls come from mise)
    yaml-language-server
    helm-ls
    nerd-fonts.jetbrains-mono
    hackgen-font
    plemoljp-nf
    # snacks.nvim uses these to show Mermaid diagrams and images in Markdown
    imagemagick
    # Nix's mermaid-cli ships no browser on macOS, so it uses Chrome installed with Homebrew
    (writeShellScriptBin "mmdc" ''
      export PUPPETEER_EXECUTABLE_PATH="''${PUPPETEER_EXECUTABLE_PATH:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
      exec ${mermaid-cli}/bin/mmdc "$@"
    '')
  ];

  # gcloud ships its own CA list and updates it late (it still trusted the compromised eMudhra root)
  home.sessionVariables.CLOUDSDK_CORE_CUSTOM_CA_CERTS_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # lazy.nvim rewrites lazy-lock.json, so link to ~/dotfiles instead of the Nix store
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";

  programs.lazygit.enable = true;

  programs.bat = {
    enable = true;
    config.theme = "Solarized (dark)";
  };

  programs.git = {
    enable = true;
    settings = {
      credential."https://github.com".helper = [
        ""
        "!${pkgs.gh}/bin/gh auth git-credential"
      ];
      credential."https://gist.github.com".helper = [
        ""
        "!${pkgs.gh}/bin/gh auth git-credential"
      ];
      # The Claude Code sandbox passes this via GIT_CONFIG_PARAMETERS, but pre-commit clears that variable
      http.proxyAuthMethod = "basic";
    };
  };

  programs.mise = {
    enable = true;
    globalConfig = {
      tools = {
        terraform = "latest";
        kubectl = "latest";
        kustomize = "latest";
        go = "latest";
        # gopls can't read a go.mod newer than the Go it was built with, so build it with mise's Go instead of Nix
        "go:golang.org/x/tools/gopls" = "latest";
        # Used by nvim-treesitter to build parsers
        tree-sitter = "latest";
        # The Nix package ships without provider schemas, so aws_* and other resources don't complete
        terraform-ls = "latest";
        node = "lts";
        pnpm = "latest";
        uv = "latest";
        python = "latest";
        "github:raine/workmux" = "latest";
      };
      settings.idiomatic_version_file_enable_tools = [ "node" ];
    };
  };

  services.colima = {
    enable = true;
    profiles.default = {
      isActive = true;
      isService = true;
      setDockerHost = true;
      settings = {
        # Same as the default, but without runtime Colima treats this file as empty and starts with defaults
        runtime = "docker";
        cpu = 4;
        memory = 6;
        disk = 100;
        vmType = "vz";
        mountType = "virtiofs";
        # Without mounts nothing is mounted, and the host side of docker run -v is empty
        mounts = [
          {
            location = "~";
            writable = true;
          }
        ];
        # For hot reload in containers
        mountInotify = true;
        kubernetes.enabled = true;
      };
    };
  };

  # Colima forwards ports the VM listens on for all interfaces (the k3s API, docker run -p, ...) to all
  # interfaces on the Mac, exposing them to the LAN. Colima has no setting for this, so a lima override
  # binds them to localhost (its rules take precedence over Colima's)
  home.file."${config.services.colima.colimaHomeDir}/_lima/_config/override.yaml".text = ''
    portForwards:
      - guestIPMustBeZero: true
        guestIP: 0.0.0.0
        hostIP: 127.0.0.1
        proto: tcp
      - guestIPMustBeZero: true
        guestIP: 0.0.0.0
        hostIP: 127.0.0.1
        proto: udp
  '';

  # Testcontainers mounts the DOCKER_HOST socket into Ryuk, but the Mac-side socket doesn't work inside the VM
  home.sessionVariables.TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = "/var/run/docker.sock";

  # Enabled to add Ghostty's shell integration to zsh (it also works inside tmux). The config is linked below
  programs.ghostty = {
    enable = true;
    # Installed with Homebrew
    package = null;
  };

  # Ghostty's config is tweaked often, so link to ~/dotfiles instead of the Nix store (Cmd+Shift+, in Ghostty reloads it)
  xdg.configFile."ghostty".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/ghostty";

  # workmux writes settings chosen in its dashboard (such as the theme) back to this file, so link to ~/dotfiles
  xdg.configFile."workmux/config.yaml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/workmux/config.yaml";

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/go/bin"
  ];

  # Not home.sessionPath, which prepends; append so that Nix packages take precedence
  programs.zsh.envExtra = ''
    (( ''${path[(Ie)/opt/homebrew/bin]} )) || path+=(/opt/homebrew/bin)
  '';

  # Karabiner rewrites karabiner.json from its GUI and misses changes through a file link, so link the whole folder
  xdg.configFile."karabiner".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/karabiner";

  targets.darwin.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
    };
    "com.apple.dock" = {
      autohide = true;
      show-recents = false;
    };
    "com.apple.finder" = {
      ShowPathbar = true;
    };
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
  };
}
