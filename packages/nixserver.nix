{ pkgs, ... }: {
    environment.defaultPackages = with pkgs; [
        bat
        btop
        mergerfs
        snapraid
        zoxide
        zsh
    ];

    programs.zsh.enable = true;
}
