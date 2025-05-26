{ config, pkgs, vars, ... }: {
    imports = [
        ./../../packages/base.nix
        ./../../packages/nixserver.nix
        ./../../packages/secrets.nix
    ];

    networking.hostName = "nixserver";

    users.users.alfred = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.userpasswd.path;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ vars.sshPublicKeyHomeserver ];
        shell = pkgs.zsh;
    };

    # boot remote unlock
    boot.kernelParams = [ "ip=localaddr::gateway:mask:hostname:interface:off:1.1.1.1:8.8.8.8:" ];
    boot.initrd.network = {
        enable = true;
        ssh = {
            enable = true;
            shell = "/bin/cryptsetup-askpass";
            authorizedKeys = config.users.users.${vars.userName}.openssh.authorizedKeys.keys;
            hostKeys = [];
        };
    };
}
