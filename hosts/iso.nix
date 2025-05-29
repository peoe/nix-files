{ vars, ... }: {
    imports = [
        ./../packages/base.nix
        ./../packages/install.nix
    ];

    networking.hostName = "nixos-iso";

    users.mutableUsers = false;
    users.users.installer = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ vars.sshPublicKeyHomeserver ];
    };

    security.sudo.wheelNeedsPassword = false;
}
