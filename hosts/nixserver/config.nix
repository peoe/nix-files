{ config, inputs, lib, outputs, pkgs, vars, ... }: {
    imports = [
        inputs.home-manager.nixosModules.home-manager
        inputs.impermanence.nixosModules.impermanence
        
        ./disk-config.nix
        ./root_diff.nix

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

    environment.persistence."/persist" = {
        directories = [
            "/nix"
            "/var/lib/nixos"
            "/var/log"
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
        preLVMCommands = lib.mkOrder 400 "sleep 2";

        # erase impermanent files
        postResumeCommands = lib.mkAfter ''
        mkdir -p /mnt
        mount "/dev/mapper/crypted" /mnt -o subvol=/

        btrfs subvolume list -o /mnt/root |
        cut -f9 -d' ' |
        while read subvolume; do
        echo "deleting /$subvolume subvolume..."
        btrfs subvolume delete "/mnt/$subvolume"
        done &&
        echo "deleting /root subvolume..." &&
        btrfs subvolume delete /mnt/root

        echo "restoring blank /root subvolume..."
        btrfs subvolume snapshot /mnt/root-blank /mnt/root

        umount /mnt
        '';
    };

    system.stateVersion = "25.05";
}
