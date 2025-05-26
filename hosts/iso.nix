{ vars, ... }: {
    imports = [
        ./../packages/base.nix
        ./../packages/install.nix
    ];

    networking.hostName = "nixos-iso";

    users.users.nixos = {
        hashedPassword = "";
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ vars.sshPublicKeyHomeserver ];
    };

    security.pam.allowNullPasswords = true;
    security.sudo.wheelNeedsPassword = false;
}
