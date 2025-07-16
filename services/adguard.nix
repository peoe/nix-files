let
    adguardport = 3000;
in {
    networking = {
        firewall = {
            allowedTCPPorts = [ adguardport ];
            allowedUDPPorts = [ 53 ];
        };
    };

    services.adguardhome = {
        enable = true;
        openFirewall = true;
        port = adguardport;
        mutableSettings = false;
        settings = {
            http = { address = "127.0.0.1:" + adguardport; };
            dns = {
                upstream_dns = [ "192.168.178.1#fritz.box" "192.168.178.1:53" ];
                upstream_mode = "parallel";
                bootstrap_dns = [ "9.9.9.10" "149.112.112.10" "2620:fe::10" "2620:fe::fe:10" ];
            };
            filtering = {
                protection_enabled = true;
                filtering_enabled = true;
                parental_enabled = false;
                safe_search = { enabled = false; };
                rewrites = [ { domain = "*.lab-leman.ipv64.de"; answer = "192.168.178.5"; } ];
            };
            filters = map(url: { enabled = true; url = url; }) [
                "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"  # Adguard DNS
                "https://adguardteam.github.io/HostlistsRegistry/assets/filter_4.txt"  # Dan Pollock
                "https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt" # Phishing
                "https://adguardteam.github.io/HostlistsRegistry/assets/filter_12.txt" # Malware
            ];
        };
    };
}
