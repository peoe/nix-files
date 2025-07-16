{ config, lib, pkgs, ... }: let
    mealieport = 3002;
in {
    networking = {
        firewall = {
            allowedTCPPorts = [ mealieport 80 443 ];
        };
    };

    services.postgresql = {
        enable = true;

        dataDir = "/data/private/postgresql/${config.services.postgresql.package.psqlSchema}";
        ensureDatabases = [ "mealie" ];
        ensureUsers = [{
            name = "mealie";
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

    services.mealie = {
        enable = true;
        port = mealieport;
        listenAddress = "127.0.0.1";
        settings = {
            ALLOW_SIGNUP = "false";
            TOKEN_TIME = 336;
            DB_ENGINE = "postgres";
            POSTGRES_DB = "mealie?host=/run/postgresql";
        };
    };

    fileSystems."/var/lib/private/mealie" = {
        depends = [
            "/data"
        ];
        device = "/data/private/mealie";
        options = [ "bind" ];
    };
}
