{ vars, ... }: {
    imports = [
        ./../packages/base.nix
        ./../packages/install.nix
    ];

    networking.hostName = "nixos-iso";

    users.users.nixos = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ vars.sshPublicKeyHomeserver ];
    };

    security.sudo.wheelNeedsPassword = false;

    services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
    };
    systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

    nix = {
        settings.experimental-features = [ "nix-command" "flakes" ];
        extraOptions = "experimental-features = nix-command flakes";
    };
}
