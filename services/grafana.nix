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
                {
                    name = "Loki";
                    type = "loki";
                    url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
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

            ingester = {
                lifecycler = {
                    address = "127.0.0.1";
                    ring = {
                        kvstore = {
                            store = "inmemory";
                        };
                        replication_factor = 1;
                    };
                };
                chunk_idle_period = "1h";
                max_chunk_age = "1h";
                chunk_target_size = 999999;
                chunk_retain_period = "30s";
                max_transfer_retries = 0;
            };

            schema_config = {
                configs = [
                    {
                        from = "2022-06-06";
                        store = "tsdb";
                        object_store = "filesystem";
                        schema = "v13";
                        index = {
                            prefix = "index_";
                            period = "24h";
                        };
                    }
                ];
            };

            storage_config = {
                tsdb_shipper = {
                    active_index_directory = "/var/lib/loki/tsdb-shipper-active";
                    cache_location = "/var/lib/loki/tsdb-shipper-cache";
                    cache_ttl = "24h";
                    shared_store = "filesystem";
                };

                filesystem = {
                    directory = "/var/lib/loki/chunks";
                };
            };

            limits_config = {
                reject_old_samples = true;
                reject_old_samples_max_age = "168h";
            };

            chunk_store_config = {
                max_look_back_period = "0s";
            };

            table_manager = {
                retention_deletes_enabled = false;
                retention_period = "0s";
            };

            compactor = {
                working_directory = "/var/lib/loki";
                shared_store = "filesystem";
                compactor_ring = {
                    kvstore = {
                        store = "inmemory";
                    };
                };
            };
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
