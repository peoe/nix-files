{ ... }: let
    mealieport = 3002;
in {
    networking = {
        firewall = {
            allowedTCPPorts = [ mealieport 80 443 ];
        };
    };

    services.mealie = {
        enable = true;
        port = mealieport;
        listenAddress = "127.0.0.1";
        settings = {
            ALLOW_SIGNUP = "false";
            TOKEN_TIME = 336;
        };
    };
}
