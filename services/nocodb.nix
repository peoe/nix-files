{ config, inputs, lib, pkgs, ... }: let
    nocodbport = 3003;
in {
    imports = [
        inputs.nocodb.nixosModules.nocodb
    ];

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    services.nocodb = {
        enable = true;
        environment = {
            DB_URL="nocodb?host=/run/postgresql";

            PORT = "${toString nocodbport}";

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
