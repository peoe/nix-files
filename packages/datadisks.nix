{ config, pkgs, ... }: {
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

    services.snapraid = {
        enable = true;
        parityFiles = [
            # must NOT be on the data disks
            "/mnt/disks/parity1/snapraid.parity"
        ];
        contentFiles = [
            "/mnt/cache/.snapraid.parity"
            "/mnt/disks/parity1/.snapraid.parity"
            "/mnt/disks/data1/.snapraid.parity"
            "/persist/.snapraid.parity"
        ];
        dataDisks = {
            cache = "/mnt/cache";
            data1 = "/mnt/disks/data1";
        };
        sync.interval = "04:00";
        scrub.interval = "weekly";
        exclude = [
            "lost+found"
            ".DS_Store"
            ".Thumbs.db"
            "*.unrecoverable"
        ];
    };

    mfs_time = pkgs.writeShellScriptBin "mergerfs_time_based_mover"
        ''
        #!/usr/bin/env sh
        if [ $# != 3 ]; then
            echo "usage: $0 <cache-fs> <backing-pool> <days-old>"
            exit 1
        fi
        CACHE="${1}"
        BACKING="${2}"
        N=${3}
        find "${CACHE}" -type f -atime +${N} -printf '%P\n' | rsync --files-from=- -axqHAXWES --preallocate --remove-source-files "${CACHE}/" "${BACKING}/"
        '';
    mfs_percentage = pkgs.writeShellScriptBin "mergerfs_percentage_based_mover"
        ''
        #!/usr/bin/env sh
        if [ $# != 3 ]; then
            echo "usage: $0 <cache-fs> <backing-pool> <percentage>"
            exit 1
        fi
        CACHE="${1}"
        BACKING="${2}"
        PERCENTAGE=${3}
        set -o errexit
        while [ $(df --output=pcent "${CACHE}" | grep -v Use | cut -d'%' -f1) -gt ${PERCENTAGE} ]
        do
            FILE=$(find "${CACHE}" -type f -printf '%A@ %P\n' | sort | head -n 1 | cut -d' ' -f2-)
            test -n "${FILE}"
            rsync -axqHAXWESR --preallocate --relative --remove-source-files "${CACHE}/./${FILE}" "${BACKING}/"
        done
        '';
    environment.systemPackages = [
        mfs_time
        mfs_percentage
    ];

    services.cron = {
        enable = true;
        systemCronJobs = [
            "0 4 */7 * * mergerfs_time_based_mover /mnt/cache /cacheddata 30" # atime based mover every week
            "0 4 */7 * * mergerfs_percentage_based_mover /mnt/cache /cacheddata 90" # percentage full based mover every week
        ];
    };
}
