{ inputs, ... }: {
    imports = [
        inputs.sops-nix.nixosModules.sops
    ];
    sops = {
        defaultSopsFile = ./../secrets/secrets.yaml;
        age.sshKeyPaths = [ "/nix/secret/initrd/ssh_host_ed25519_key" ];
        secrets.userpasswd.neededForUsers = true;
        secrets.userpasswd = {};
        gnupg.sshKeyPaths = [];
    };
}
