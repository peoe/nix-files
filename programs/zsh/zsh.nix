{ lib, ... }: {
    home.shell.enableZshIntegration = true;

    programs.zsh = {
        enable = true;

        enableCompletion = true;
        autocd = true;
        autosuggestion = {
            enable = true;
            strategy = [ "history" "completion" ];
        };

        completionInit = ''
        autoload -Uz compinit && compinit
        zstyle ':completion:*' menu select # enable menu style completion
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}  # colorized completion
        zstyle ':completion:*' squeeze-slashes yes  # remove trailing slashes
        zstyle ':completion:*:warnings' format "$fg[red]No matches for:$reset_color %d"
        '';

        history = {
            save = 5000;
            size = 5000;
            ignoreAllDups = true;
            append = true;
        };

        initContent = lib.mkOrder 1000 (builtins.readFile ./init);

        shellAliases = {
            ls = "gls -A --group-directories-first --color=auto";

            nrs = "nixos-rebuild switch --flake github:peoe/nix-files#nixserver";
            nrt = "nixos-rebuild test --flake github:peoe/nix-files#nixserver";

            # git aliases
            ga = "git add";
            gc = "git commit -m";
            gch = "git switch";
            gd = "git diff --color";
            gfa = "git fetch --all --prune";
            gi = "git status --short";
            gl = "git log --oneline --decorate --graph";
            gp = "git push";
            gpl = "git pull";
            gup = "git push --set-upstream";
        };

        syntaxHighlighting = {
            enable = true;
            highlighters = [ "main" "brackets" ];
        };
    };
}
