{ config, vars, ... }: let
    grafanaport = 3001;
in {
    networking = {
        firewall = {
            allowedTCPPorts = [ grafanaport 80 443 ];
        };
    };

    services.grafana = {
        enable = true;
        
        settings = {
            server = {
                domain = "graphs.${toString vars.base_url}";
                http_port = grafanaport;
                http_addr = "127.0.0.1";
            };

            users.allow_sign_up = false;
        };
    };
}
