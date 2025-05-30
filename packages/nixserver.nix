{ pkgs, ... }: {
    environment.defaultPackages = with pkgs; [
        bat
        btop
        g-ls
        mergerfs
        snapraid
        zoxide
        zsh
    ];

    programs.zsh.enable = true;

    # ensure that terminfo is correct
    environment.sessionVariables = {
        TERMINFO_DIRS = "/run/current-system/sw/share/terminfo";
    };
}
