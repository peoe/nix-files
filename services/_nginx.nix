{ config, vars, ... }: {
    services.nginx = {
        enable = true;

        virtualHosts = {
            "ads.${toString vars.base_url}" = {
                forceSSL = true;
                useACMEHost = vars.base_url;

                locations."/" = {
                    proxyPass = "http://127.0.0.1:${toString config.services.adguardhome.port}";
                    proxyWebsockets = true;
                };
            };
            "graphs.${toString vars.base_url}" = {
                forceSSL = true;
                useACMEHost = vars.base_url;

                locations."/" = {
                    proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
                    proxyWebsockets = true;
                };
            };
            "mealie.${toString vars.base_url}" = {
                forceSSL = true;
                useACMEHost = vars.base_url;

                locations."/" = {
                    proxyPass = "http://127.0.0.1:${toString config.services.mealie.port}";
                    proxyWebsockets = true;
                };
            };
            "books.${toString vars.base_url}" = {
                forceSSL = true;
                useACMEHost = vars.base_url;

                locations."/" = {
                    proxyPass = "http://127.0.0.1:3003";
                    proxyWebsockets = true;
                };
            };
            "jellyfin.${toString vars.base_url}" = {
                forceSSL = true;
                useACMEHost = vars.base_url;

                locations."/" = {
                    proxyPass = "http://127.0.0.1:8096";
                    proxyWebsockets = true;
                };
            };
        };
    };
}
