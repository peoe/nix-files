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

    programs."g-ls".enable = true;
    programs.zsh.enable = true;

    # ensure that terminfo is correct
    environment.sessionVariables = {
        TERMINFO_DIRS = "/run/current-system/sw/share/terminfo";
    };
}
