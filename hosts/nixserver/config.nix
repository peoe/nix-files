{ pkgs, vars, ... }: {
    imports = [
        ./../../packages/base.nix
        ./../../packages/nixserver.nix
    ];

    networking.hostName = "nixserver";

    users.users.alfred = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ vars.sshPublicKeyHomeserver ];
        shell = pkgs.zsh;
    };
}
