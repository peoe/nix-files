{ vars, ... }: {
    imports = [
        ./../packages/base.nix
        ./../packages/install.nix
    ];

    networking.hostName = "nixos-iso";

    # users.users.nixos = {
    #     initialPassword = "password";
    #     isNormalUser = true;
    #     extraGroups = [ "wheel" ];
    #     openssh.authorizedKeys.keys = [ vars.sshPublicKeyHomeserver ];
    # };
    users.users.root.openssh.authorizedKeys.keys = [vars.sshPublicKeyHomeserver];
}
