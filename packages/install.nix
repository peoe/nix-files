{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        (
            writeShellScriptBin "install_nixos"
            ''
            #!/usr/bin/env bash
            # clone relevant config
            git clone https://github.com/peoe/nix-files.git

            # format, set luks, mount
            sudo nix run github:nix-community/disko/latest -- --mode destroy,format,mount ~/nix-files/hosts/nixserver/disk-config.nix --yes-wipe-all-disks
            sudo mkdir -pv /mnt/nix/secret/initrd
            sudo mkdir -pv /mnt/persist/etc/ssh
            sudo mkdir -pv /mnt/persist/var/lib

            # temporary dir for caching flakes
            sudo mkdir -pv /mnt/Flake/tmp

            # initrd hostkey and sops key
            sudo ssh-keygen -t ed25519 -N "" -C "" -f /mnt/persist/etc/ssh/ssh_host_ed25519_key
            sudo cp /mnt/persist/etc/ssh/ssh_host_ed25519_key /mnt/nix/secret/initrd
            sudo nix-shell --extra-experimental-features flakes -p ssh-to-age --run 'cat /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
            echo -e "Remember to update .sops.yaml, and call"
            echo ""
            echo -e "\t\033[1mfor file in secrets/*; do sops updatekeys "$file"; done\033[0m"
            echo ""
            echo -e "in the nix repo. Add, commit, and push the changes to Github before continuing!"
            echo -e "To install NixOS configuration for hostname, run the following command:"
            echo ""
            echo -e "\t\033[1mTMPDIR=/mnt/Flake/tmp sudo nixos-install --no-root-passwd --no-write-lock-file --root /mnt --flake github:peoe/nix-files#hostname\033[0m"
            ''
        )
    ];
}
