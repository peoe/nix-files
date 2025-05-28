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
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG1opVYCJ/gVwaTSrEWFS9romQryj0JGqY3IYQnmL8tV Homeserver" ];
    };

    security.sudo.wheelNeedsPassword = false;
}
