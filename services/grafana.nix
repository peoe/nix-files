{ config, vars, ... }: {
    services.grafana = {
        enable = true;
        domain = "graphs.lab-leman";
        port = 3000;
        addr = "127.0.0.1";
        
        settings = {
            security = {
                admin_user = vars.userName;
                admin_password = config.sops.secrets.grafanapasswd.path;
            };
        };
    };
}
