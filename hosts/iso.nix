{ vars, ... }: {
    imports = [
        ./../packages/base.nix
        ./../packages/install.nix
    ];

    networking.hostName = "nixos-iso";

    users.users.nixos = {
        initialHashedPassword = "";
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ vars.sshPublicKeyHomeserver ];
    };

    security.sudo.wheelNeedsPassword = false;
}
