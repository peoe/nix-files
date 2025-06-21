{    
    fileSystems."/persist".neededForBoot = true;

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
                                settings.allowDiscards = true;
                                content = {
                                    type = "btrfs";
                                    extraArgs = [ "-f" ];
                                    subvolumes = {
                                        "/root" = {
                                            mountpoint = "/";
                                            mountOptions = [
                                                "subvol=root"
                                                "compress=zstd"
                                                "noatime"
                                            ];
                                        };
                                        "/persist" = {
                                            mountpoint = "/persist";
                                            mountOptions = [
                                                "subvol=persist"
                                                "compress=zstd"
                                                "noatime"
                                            ];
                                        };
                                        "/persist/nix" = {
                                            mountpoint = "/nix";
                                            mountOptions = [
                                                "subvol=nix"
                                                "compress=zstd"
                                                "noatime"
                                            ];
                                        };
                                        "/persist/var/log" = {
                                            mountpoint = "/var/log";
                                            mountOptions = [
                                                "subvol=log"
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
