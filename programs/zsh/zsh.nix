{ lib, vars, ... }: {
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
            path = "$HOME/.local/share/zsh/.zsh_history";
            save = 5000;
            size = 5000;
            ignoreAllDups = true;
            append = true;
        };

        initContent = lib.mkOrder 1000 (builtins.readFile ./init);

        shellAliases = {
            ls = "g -A --group-directories-first --color=auto";
            ll = "g -A --group-directories-first --color=auto -l";

            ngc = "nix-collect-garbage -d";
            nrs = "sudo nixos-rebuild switch --flake github:peoe/nix-files#nixserver --no-write-lock-file";
            nrt = "sudo nixos-rebuild test --flake github:peoe/nix-files#nixserver --no-write-lock-file";

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

    # persist zsh history
    home.persistence."/persist/home/${vars.userName}" = {
        directories = [
            ".local/share/zsh"
        ];
        allowOther = true;
    };
}
