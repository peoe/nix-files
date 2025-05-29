{
    # enable suggestions for system packages
    environment.pathsToLink = [ "/share/zsh" ];

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
        autoload -Uz bashcompinit && bashcompinit
        '';
        history = {
            size = 10000;
            ignoreAllDups = true;
            };
        syntaxHighlighting = {
            enable = true;
            highlighters = [ "main" "brackets" ];
        };
    };
}
