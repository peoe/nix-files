{ vars, ... }: {
    imports = [];

    networking.hostName = "nixserver";

    users.users.alfred = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ vars.sshPublicKeyHomeserver ];
    };

    services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
    };

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
