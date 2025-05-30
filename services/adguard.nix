let
    adguardport = 3000;
in {
    networking = {
        firewall = {
            allowedTCPPorts = [ adguardPort ];
            allowedUDPPorts = [ 53 ];
        };
    };

    services.adguardhome = {
        enable = true;
        openFirewall = true;
        port = adguardPort;
        settings = {
            http = { address = "127.0.0.1:3003"; };
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
                "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"  # The Big List of Hacked Malware Web Sites
                "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # malicious url blocklist
            ];
        };
    };
}
