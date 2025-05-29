{
    programs.zsh = {
        enable = true;
        enableCompletions = true;
        autocd = true;
        autosuggestions.enable = true;
        completionInit = ''
        autoload -Uz compinit && compinit
        autoload -Uz bashcompinit && bashcompinit
        '';
        history = {
            size = 10000;
            ignoreAllDups = true;
            };
        syntaxHighlighting.enable = true;
    };
}
