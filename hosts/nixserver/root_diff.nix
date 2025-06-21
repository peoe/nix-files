{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        (
            writeShellScriptBin "root-diff"
            ''
            #!/usr/bin/env bash
            sudo mkdir -p /mnt
            sudo mount "/dev/mapper/crypted" /mnt -o subvol=/
            set -euo pipefail
            OLD_TRANSID=$(sudo btrfs subvolume find-new /mnt/root-snapshot 9999999)
            OLD_TRANSID=''${OLD_TRANSID}
            sudo btrfs subvolume find-new "/mnt/root" "$OLD_TRANSID" |
            sed '$d' |
            cut -f17- -d' ' |
            sort |
            uniq |
            while read path; do
              path="/$path"
              if [ -L "$path" ]; then
                : # The path is a symbolic link, so is probably handled by NixOS already
              elif [ -d "$path" ]; then
                : # The path is a directory, ignore
              else
                echo "$path"
              fi
            done
            ''
        )
    ];
}
