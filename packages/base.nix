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
            PermitEmptyPasswords = "yes";
            PermitRootLogin = "no";
        };
        authorizedKeysFiles = [./../pubkey];
    };
    systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

    nix = {
        settings.experimental-features = [ "nix-command" "flakes" ];
        extraOptions = "experimental-features = nix-command flakes";
    };
}
