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
    virtualisation.oci-containers.backend = "podman";

    virtualisation.oci-containers.containers."nocodb" = {
        autoStart = true;
        login = {
            registry = "docker.io";
            username = "peoe";
            passwordFile = config.sops.secrets.dockerpasswd.path;
        };
        image = "nocodb/nocodb:0.263.8";
        volumes = [
            "/data/private/nocodb:/usr/app/data"
            "/run/postgresql:/run/postgresql"
        ];
        ports = [
            "${toString nocodbport}:${toString nocodbport}"
        ];
        log-driver = "journald";
        environment = {
            TZ = config.time.timeZone;
            DB_URL = "nocodb?host=/run/postgresql";
        };
    };

    fileSystems."/var/lib/containers/storage" = {
        depends = [
            "/data"
        ];
        device = "/data/containers/storage";
        options = [ "bind" ];
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
