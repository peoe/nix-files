{ inputs, ... }: {
    imports = [
        inputs.sops-nix.nixosModules.sops
    ];
    sops = {
        defaultSopsFile = ./../secrets/secrets.yaml;
        age.sshKeyPaths = [ "/nix/secret/initrd/ssh_host_ed25519_key" ];

        # get user password for boot
        secrets.userpasswd.neededForUsers = true;
        secrets.userpasswd = {};

        # get luks-key file for unlocking data drives on boot
        secrets."luks-key" = {
            format = "binary";
            sopsFile = ./../secrets/luks-key;
        };

        secrets.dockerpasswd = {};

        gnupg.sshKeyPaths = [];
    };
}
