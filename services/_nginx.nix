{ config, ... }: let
    base_url = "lab-leman";
in {
    services.nginx = {
        enable = true;

        virtualHosts = {
            "ads.${toString base_url}" = {
                locations."/" = {
                    proxyPass = "http://127.0.0.1:${toString config.services.adguardhome.port}";
                    proxyWebsockets = true;
                };
            };
            "graphs.${toString base_url}" = {
                locations."/" = {
                    proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
                    proxyWebsockets = true;
                };
            };
            "mealie.${toString base_url}" = {
                locations."/" = {
                    proxyPass = "http://127.0.0.1:${toString config.services.mealie.port}";
                    proxyWebsockets = true;
                };
            };
        };
    };
}
