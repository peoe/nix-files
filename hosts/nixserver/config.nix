{ config, inputs, lib, outputs, pkgs, vars, ... }: {
    imports = [
        inputs.home-manager.nixosModules.home-manager
        inputs.impermanence.nixosModules.impermanence
        
        ./disk-config.nix
        ./root_diff.nix

        ./../../packages/base.nix
        ./../../packages/datadisks.nix
        ./../../packages/nixserver.nix
        ./../../packages/secrets.nix

        ./../../services/adguard.nix
        ./../../services/grafana.nix
        ./../../services/mealie.nix
        ./../../services/nocodb.nix
        ./../../services/_acme.nix
        ./../../services/_nginx.nix
    ];

    networking.hostName = "nixserver";
    time.timeZone = "Europe/Zurich";

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
                inputs.impermanence.homeManagerModules.impermanence

                ./../../programs/default.nix
            ];
        };
    };

    environment.persistence."/persist" = {
        directories = [
            "/var/lib/nixos"
        ];

        files = [
            "/etc/machine-id"
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"
            "/etc/ssh/ssh_host_rsa_key"
            "/etc/ssh/ssh_host_rsa_key.pub"
        ];
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
        preLVMCommands = lib.mkOrder 400 "sleep 5";

        # erase impermanent files
        postResumeCommands = lib.mkAfter ''
        MNTPOINT=$(mktemp -d)
        mount "/dev/mapper/crypted" "$MNTPOINT" -o subvol=/

        if [[ -e "$MNTPOINT/root" ]]; then
            mv "$MNTPOINT/root" "$MNTPOINT/old_root"
        fi

        btrfs subvolume delete "$MNTPOINT/old_root"
        btrfs subvolume create "$MNTPOINT/root"
        umount "$MNTPOINT"
        '';
    };

    system.stateVersion = "25.05";
}
