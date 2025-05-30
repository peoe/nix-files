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
        settings = {
            http = { address = "127.0.0.1:" + adguardport; };
            dns = { upstream_dns = [ "192.168.178.1#fritz.box" "192.168.178.1:53" ]; };
            filtering = {
                protection_enabled = true;
                filtering_enabled = true;
                parental_enabled = false;
                safe_search = { enabled = false; };
            };
            # The following notation uses map
            # to not have to manually create {enabled = true; url = "";} for every filter
            # This is, however, fully optional
            filters = map(url: { enabled = true; url = url; }) [
                "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"  # Adguard DNS
                "https://adguardteam.github.io/HostlistsRegistry/assets/filter_4.txt"  # Dan Pollock
                "https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt" # Phishing
                "https://adguardteam.github.io/HostlistsRegistry/assets/filter_12.txt" # Malware
            ];
        };
    };
}
