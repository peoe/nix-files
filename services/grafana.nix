{ config, vars, ... }: let
    grafanaport = 3000;
in {
    networking = {
        firewall = {
            allowedTCPPorts = [ grafanaport 80 443 ];
        };
    };

    services.grafana = {
        enable = true;
        domain = "graphs.lab-leman";
        port = grafanaport;
        addr = "127.0.0.1";
        
        settings = {
            security = {
                admin_user = vars.userName;
            };
        };
    };
}
