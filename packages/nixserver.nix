{ pkgs, ... }: {
    environment.defaultPackages = with pkgs; [
        bat
        btop
        g-ls
        mergerfs
        snapraid
        zoxide
    ];
}
