{
    inputs,
    outputs,
    vars,
    ...
}: {
    imports = [];

    networking.hostName = "nixserver";

    users.users.alfred = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ vars.sshPublicKeyHomeserver ];
    };

    services.openssh{
        enable = true;
        passwordAuthentication = false;
    };

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
