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
        syntaxHighlighting = {
            enable = true;
            highlighters = [ "main" "brackets" ];
        };
    };
}
