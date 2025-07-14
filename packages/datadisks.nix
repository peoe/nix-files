{ config, ... }: {
    # crypttab to luksOpen at boot from decryption key
    environment.etc.crypttab = {
        mode = "0600";
        text = ''
        # <volume-name> <encrypted-device> [key-file] [options]
        cache /dev/disk/by-label/cache ${config.sops.secrets."luks-key".path}

        data1 /dev/disk/by-label/data1 ${config.sops.secrets."luks-key".path}

        parity1 /dev/disk/by-label/parity1 ${config.sops.secrets."luks-key".path}
        '';
    };

    # simple data disks
    fileSystems."/mnt/disks/data1" = {
        device = "/dev/mapper/data1";
        fsType = "ext4";
        options = [
            "defaults"
            "noatime"
        ];
    };
    fileSystems."/mnt/cache" = {
        device = "/dev/mapper/cache";
        fsType = "ext4";
        options = [
            "defaults"
            "noatime"
        ];
    };

    # mergerfs filesystems for caching
    fileSystems."/cacheddata" = {
        depends = [
            "/mnt/cache"
            "/mnt/disks/data1"
        ];
        device = "/mnt/cache:/mnt/disks/data*";
        fsType = "mergerfs";
        options = [
            "defaults"
            "category.create=ff"
            "fsname=cacheddata"
        ];
    };
    fileSystems."/data" = {
        depends = [
            "/mnt/disks/data1"
        ];
        device = "/mnt/disks/data*";
        fsType = "mergerfs";
        options = [
            "defaults"
            "category.create=ff"
            "fsname=data"
        ];
    };

    # snapraid parity disk
    fileSystems."/mnt/disks/parity1" = {
        device = "/dev/mapper/parity1";
        fsType = "ext4";
        options = [
            "defaults"
            "noatime"
        ];
    };
}
