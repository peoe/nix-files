{ config, inputs, lib, pkgs, ... }: let
    nocodbport = 3003;
in {
    networking.firewall.interfaces."podman+".allowedUDPPorts = [53];

    virtualisation.podman = {
        enable = true;
        autoPrune.enable = true;
        dockerCompat = true;
        defaultNetwork.settings = {
            # Required for container networking to be able to use names.
            dns_enabled = true;
        };
    };
    virtualisation.containers.storage.settings = {
        graphroot = "/data/containers/storage";
    };
    virtualisation.oci-containers.backend = "podman";

    virtualisation.oci-containers.containers."nocodb" = {
        image = "nocodb:0.263.8";
        volumes = [
            "/data/private/nocodb:/usr/app/data"
            "/run/postgresql:/run/postgresql"
        ];
        ports = [
            "8096:8096"
        ];
        log-driver = "journald";
        environment = {
            TZ = config.time.timeZone;
            DB_URL = "nocodb?host=/run/postgresql";
        };
    };

    services.postgresql = {
        enable = true;

        dataDir = "/data/private/postgresql/${config.services.postgresql.package.psqlSchema}";
        ensureDatabases = [ "nocodb" ];
        ensureUsers = [{
            name = "nocodb";
            ensureDBOwnership = true;
        }];

        settings.log_timezone = config.time.timeZone;
    };
}
