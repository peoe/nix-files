{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        git
        gptfdisk
        neovim
        parted
    ];

    services.openssh = {
        enable = true;
        settings = {
            PasswordAuthentication = false;
            PermitRootLogin = "no";
        };
    };
    systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

    nix = {
        settings.experimental-features = [ "nix-command" "flakes" ];
        extraOptions = "experimental-features = nix-command flakes";
    };
}
