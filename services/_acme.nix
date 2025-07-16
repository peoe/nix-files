{ config, vars, ... }: {
    sops.secrets = {
        "ipv64-api-key" = {};
    };

    security.acme = {
        acceptTerms = true;
        defaults.email = "oehme.pb@gmail.com";

        certs."${toString vars.base_url}" = {
            domain = vars.base_url;
            extraDomainNames = [ "*.${toString vars.base_url}" ];
            dnsProvider = "ipv64";
            dnsPropagationCheck = true;
            credentialFiles = {
                "IPV64_API_KEY_FILE" = config.sops.secrets."ipv64-api-key".path;
            };
        };
    };

    users.users.nginx.extraGroups = ["acme"];
}
