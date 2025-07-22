{ config, ... }: let
    nocodbport = 8080;
in {
    # networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 ];

    virtualisation.podman = {
        enable = true;
        autoPrune.enable = true;
        dockerCompat = true;
        # defaultNetwork.settings = {
        #     # Required for container networking to be able to use names.
        #     dns_enabled = true;
        # };
    };
    # virtualisation.containers.storage.settings.storage = {
    #     graphroot = "/data/containers/storage";
    # };
    virtualisation.oci-containers.backend = "podman";

    virtualisation.oci-containers.containers."nocodb" = {
        # autoStart = true;
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
            "0.0.0.0:${toString nocodbport}:${toString nocodbport}"
        ];
        log-driver = "journald";
        environment = {
            TZ = config.time.timeZone;
            DB_URL = "nocodb?host=/run/postgresql";
            PORT = "${toString nocodbport}";
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
