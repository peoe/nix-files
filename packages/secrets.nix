{ inputs, ... }: {
    imports = [
        inputs.sops-nix.nixosModules.sops
    ];
    sops = {
        defaultSopsFile = ./../../secrets/secrets.yaml;
        age.sshKeyPaths = [ "/nix/secrets/initrd/ssh_host_key" ];
        secrets.userpasswd.neededForUsers = true;
        secrets.userpasswd = {};
        gnupg.sshKeyPaths = [];
    };
}
