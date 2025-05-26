{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        (
            writeShellScriptBin "install_nixos"
            ''
            #!/usr/bin/env bash
            ''
        )
        (
            writeShellScriptBin "install_nixos_with_partitioning"
            ''
            #!/usr/bin/env bash

            # Define disks
            DISK="/dev/asdf"
            DISK_BOOT="/dev/asdf1"
            DISK_NIX="/dev/asdf2"

            # Print current disk layout
            echo -e "\n\033[1mDisk Layout:\033[0m"
            lsblk
            echo ""

            # Undo previous changes
            echo -e "\n\033[1mUndoing any previous changes...\033[0m"
            set +e
            umount -R /mnt
            cryptsetup close cryptroot
            set -e
            echo -e "\033[32mPrevious changes undone.\033[0m"

            # Partitions
            echo -e "\n\033[1mPartitioning disk...\033[0m"
            parted $DISK -- mklabel gpt
            parted $DISK -- mkpart ESP fat32 1MiB 512MiB
            parted $DISK -- set 1 boot on
            parted $DISK -- mkpart NIX 512 MiB 100%
            echo -e "\033[32mDisk partitioned successfully.\033[0m"

            # Encryption
            echo -e "\n\033[1mSetting up encryption...\033[0m"
            cryptsetup -q -v luksFormat $DISK_NIX
            cryptsetup -q -v open $DISK_NIX cryptroot
            echo -e "\033[32mEncryption setup completed.\033[0m"

            # Create filesystems
            echo -e "\n\033[1mCreating filesystems...\033[0m"
            mkfs.fat -F32 -n boot $DISK_BOOT
            mkfs.btrfs -L nix /dev/mapper/cryptroot
            # Mandatory pause
            sleep 2
            echo -e "\033[32mFilesystems created successfully.\033[0m"

            # Mount points
            echo -e "\n\033[1mMounting filesystems...\033[0m"
            mkdir -pv /mnt/{boot,nix,etc/ssh,var/{lib,log}}
            mount /dev/disk/by-label/boot /mnt/boot
            mount /dev/disk/by-label/nix /mnt/nix
            mkdir -pv /mnt/nix/{secret/initrd,persist/{etc/ssh,var/{lib,log}}}
            chmod 0700 /mnt/nix/secret
            mount -o bind /mnt/nix/persist/var/log /mnt/var/log
            echo -e "\033[32mFilesystems mounted successfully.\033[0m"

            # Generate initrd SSH host key
            echo -e "\n\033[1mGenerating initrd SSH host key and converting to public age key...\033[0m"
            ssh-keygen -t ed25519 -N "" -C "" -f /mnt/nix/secret/initrd/ssh_host_key
            sudo nix-shell --extra-experimental-features flakes -p ssh-to-age --run 'cat /mnt/nix/secret/initrd/ssh_host_key.pub | ssh-to-age'
            echo -e "\033[32mAge public key generated successfully.\033[0m"

            # Completed
            echo -e "\n\033[1;32mAll steps completed successfully. NixOS is now ready to be installed.\033[0m\n"
            echo -e "Remember to commit and push the new server's public host key to sops/update all sops encrypted files before installing!\n"
            echo -e "Use the following command to update sops (replace single quotes by double quotes):\n"
            echo ""
            echo -e "\t\033[for file in secrets/*; do sops updatekeys '$file'; done\033[0m\n"
            echo ""
            echo -e "To install NixOS configuration for hostname, run the following command:\n"
            echo ""
            echo -e "\t\033[1msudo nixos-install --no-root-passwd --root /mnt --flake github:peoe/nix-files#hostname\033[0m\n"
            ''
        )
    ];
}
