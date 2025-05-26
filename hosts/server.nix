{ vars, ... }: {
    imports = [
        ./../packages/base.nix
        ./../packages/nixserver.nix
    ];

    networking.hostName = "nixserver";

    users.users.alfred = {
        initialPassword = "sesame";
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ vars.sshPublicKeyHomeserver ];
    };
}
