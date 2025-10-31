{ config, vars, ... }: let
    grafanaport = 3001;
    lokiport = 3100;
    promtailport = 3101;
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

        provision = {
            enable = true;

            datasources.settings.datasources = [
                {
                    name = "Prometheus";
                    type = "prometheus";
                    url = "http://127.0.0.1:${toString config.services.prometheus.port}";
                    isDefault = true;
                    editable = false;
                }
            ];
        };
    };

    services.loki = {
        enable = true;

        configuration = {
            server.http_listen_port = lokiport;
            auth_enabled = false;
        };
    };

    services.promtail = {
        enable = true;
        configuration = {
            server = {
                http_listen_port = promtailport;
                grpc_listen_port = 0;
            };
            positions = {
                filename = "/tmp/positions.yaml";
            };
            clients = [
                { url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push"; }
            ];
            scrape_configs = [
                {
                    job_name = "journal";
                    journal = {
                        max_age = "12h";
                        labels = {
                            job = "systemd-journal";
                            host = "nixserver";
                        };
                    };
                    relabel_configs = [
                        {
                            source_labels = [ "__journal__systemd_unit" ];
                            target_label = "unit";
                        }
                    ];
                }
                {
                    job_name = "nginx";
                    static_configs = [
                        {
                            targets = [ "127.0.0.1" ];
                            labels = {
                                job = "nginx";
                                __path__ = "/var/log/nginx/*.log";
                                host = "nixserver";
                                instance = "127.0.0.1";
                            };
                        }
                    ];
                }
            ];
        };
    };
}
