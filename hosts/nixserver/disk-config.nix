{
    disko.devices = {
        disk = {
            sda = {
                type = "disk";
                device = "/dev/sda";
                content = {
                    type = "gpt";
                    partitions = {
                        ESP = {
                            size = "512M";
                            type = "EF00";
                            content = {
                                type = "filesystem";
                                format = "vfat";
                                mountpoint = "/boot";
                                mountOptions = [ "umask=0077" ];
                            };
                        };
                        luks = {
                            size = "100%";
                            content = {
                                type = "luks";
                                name = "crypted";
                                askPassword = true;
                                # passwordFile = "/tmp/secret.key";
                                settings.allowDiscards = true;
                                content = {
                                    type = "btrfs";
                                    extraArgs = [ "-f" ];
                                    postCreateHook = ''
										MNTPOINT=$(mktemp -d)
										mount "/dev/mapper/crypted" "$MNTPOINT" -o subvol=/
										trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
										btrfs subvolume snapshot -r $MNTPOINT/root $MNTPOINT/root-snapshot
									'';
                                    subvolumes = {
                                        "/root" = {
                                            mountpoint = "/";
                                            mountOptions = [
                                                "compress=zstd"
                                                "noatime"
                                            ];
                                        };
                                        "/persist" = {
                                            mountpoint = "/persist";
                                            mountOptions = [
                                                "compress=zstd"
                                                "noatime"
                                            ];
                                            neededForBoot = true;
                                        };
                                        "/persist/nix" = {
                                            mountpoint = "/nix";
                                            mountOptions = [
                                                "compress=zstd"
                                                "noatime"
                                            ];
                                        };
                                        "/persist/var/log" = {
                                            mountpoint = "/var/log";
                                            mountOptions = [
                                                "compress=zstd"
                                                "noatime"
                                            ];
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
        };
    };
}
