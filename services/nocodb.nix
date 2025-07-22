{ config, ... }: let
    nocodbport = 3003;
in {
    virtualisation.podman = {
        enable = true;
        autoPrune.enable = true;
        dockerCompat = true;
    };
    virtualisation.oci-containers.backend = "podman";

    virtualisation.oci-containers.containers."nocodb" = {
        autoStart = true;
        login = {
            registry = "docker.io";
            username = "peoe";
            passwordFile = config.sops.secrets.dockerpasswd.path;
        };
        image = "docker.io/nocodb/nocodb:0.263.8";
        volumes = [
            "/data/private/nocodb:/usr/app/data"
            "/run/postgresql:/run/postgresql"
        ];
        ports = [
            "0.0.0.0:${toString nocodbport}:${toString nocodbport}"
        ];
        log-driver = "journald";
        environment = {
            TZ = config.time.timeZone;
            NC_DB = "pg://host.docker.internal:5432?u=nocodb";
            DB_URL = "nocodb?host=/run/postgresql";
            PORT = "${toString nocodbport}";
            NC_DASHBOARD_URL = "/";
            NC_INVITE_ONLY_SIGNUP = "true";
            NC_DISABLE_TELE = "true";
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
