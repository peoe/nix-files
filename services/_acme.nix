{
    sops.secrets = {
        "ipv64-api-key" = {};
    };

    security.acme = {
        acceptTerms = true;
        defaults.email = "oehme.pb+acme@gmail.com";

        certs."lab-leman.ipv64.de" = {
            domain = "lab-leman.ipv64.de";
            extraDomainNames = [ "*.lab-leman.ipv64.de" ];
            dnsProvider = "ipv64";
            dnsPropagationCheck = true;
            credentialFiles = {
                "IPV64_API_KEY_FILE" = config.sops.secrets."ipv64-api-key".path;
            };
        };
    };

    users.users.nginx.extraGroups = ["acme"];
}
