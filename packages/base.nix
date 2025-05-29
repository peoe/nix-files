{ pkgs, ... }: {
    # enable zsh suggestions for system packages
    environment.pathsToLink = [ "/share/zsh" ];

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
    };
    systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

    nixpkgs.config.allowUnfree = true;
    nix = {
        gc = {
            automatic = true;
            dates = "daily";
            options = "--delete-older-than 1d";
        };
        settings = {
            auto-optimise-store = true;
            experimental-features = "nix-command flakes";
        };
    };
}
