{ config, inputs, pkgs, ... }: let
    nocodbport = 3003;
in {
    imports = [
        inputs.nocodb.nixosModules.nocodb
    ];

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    services.nocodb = {
        enable = true;
        environments = {
            DB_URL="postgres:///nocodb?host=/run/postgresql";

            PORT = nocodbport;

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

        package = with pkgs; postgresql_15;
        authentication = lib.mkForce ''
            #type database DBuser  origin-address auth-method
            # unix socket
            local all      all                    trust
            # ipv4
            host  all      all     127.0.0.1/32   trust
            # ipv6
            host  all      all     ::1/128        trust
        '';

        settings.log_timezone = config.time.timeZone;
    };
}
