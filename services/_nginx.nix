{ config, ... }: {
    services.nginx = {
        enable = true;

        virtualHosts = {
            "ads.lab-leman" = {
                locations."/" = {
                    proxyPass = "http://127.0.0.1:${toString config.services.adguardhome.port}";
                    proxyWebsockets = true;
                };
            };
            ${config.services.grafana.settings.server.domain} = {
                locations."/" = {
                    proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
                    proxyWebsockets = true;
                };
            };
            "mealie.lab-leman" = {
                locations."/" = {
                    proxyPass = "http://127.0.0.1:${toString config.services.mealie.port}";
                    proxyWebsockets = true;
                };
            };
        };
    };
}
