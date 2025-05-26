{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        git
        gptfdisk
        neovim
        parted
    ];
}
