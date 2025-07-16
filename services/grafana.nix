{ vars, ... }: let
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
            security = {
                admin_user = vars.userName;
            };

            server = {
                domain = "graphs.lab-leman.ipv64.de";
                http_port = grafanaport;
                http_addr = "127.0.0.1";
            };
        };
    };
}
