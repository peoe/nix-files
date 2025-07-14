{ config, ... }: {
    environment.etc.crypttab = {
        mode = "0600";
        text = ''
        # <volume-name> <encrypted-device> [key-file] [options]
        cache /dev/disk/by-label/cache ${config.sops.secrets."luks-file".path}

        data1 /dev/disk/by-label/data1 ${config.sops.secrets."luks-file".path}

        parity1 /dev/disk/by-label/parity1 ${config.sops.secrets."luks-file".path}
        '';
    };
}
