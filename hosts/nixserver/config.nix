{ config, pkgs, vars, ... }: {
    imports = [
        ./disk-config.nix

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

    boot.loader = {
        systemd-boot = {
            enable = true;
            configurationLimit = 5;
        };
        efi.canTouchEfiVariables = true;
        timeout = 5;
    };

    # boot remote unlock
    # boot.kernelParams = [ "ip=localaddr::gateway:mask:hostname:interface:off:1.1.1.1:8.8.8.8:" ];
    boot.initrd = {
        availableKernelModules = ["r8169"];
        network = {
            enable = true;
            flushBeforeStage2 = true;
            ssh = {
                enable = true;
                shell = "/bin/cryptsetup-askpass";
                authorizedKeys = config.users.users.alfred.openssh.authorizedKeys.keys;
                hostKeys = [ "/nix/secret/initrd/ssh_host_ed25519_key" ];
            };
        };
    };

    system.stateVersion = "25.11";
}
