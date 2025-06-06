{ config, inputs, lib, outputs, pkgs, vars, ... }: {
    imports = [
        inputs.home-manager.nixosModules.home-manager
        
        ./disk-config.nix

        ./../../packages/base.nix
        ./../../packages/nixserver.nix
        ./../../packages/secrets.nix

        ./../../services/adguard.nix
        ./../../services/grafana.nix
        ./../../services/nginx.nix
    ];

    networking.hostName = "nixserver";

    users.users.${vars.userName} = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.userpasswd.path;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ vars.sshPublicKeyHomeserver ];
        shell = pkgs.zsh;
    };

    home-manager = {
        extraSpecialArgs = {inherit inputs outputs vars;};
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${vars.userName} = {
            home = {
                username = vars.userName;
                stateVersion = config.system.stateVersion;
            };

            imports = [
                ./../../programs/default.nix
            ];
        };
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
    boot.initrd = {
        availableKernelModules = ["r8169"];
        luks.forceLuksSupportInInitrd = true;

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

        # try to ensure that we wait for network device before continuing
        preLVMCommands = lib.mkOrder 400 "sleep 2";
    };

    system.stateVersion = "25.05";
}
