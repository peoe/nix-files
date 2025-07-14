{ ... }: let
    mealieport = 3002;
in {
    services.mealie = {
        enable = true;
        port = mealieport;
        listenAddress = "127.0.0.1";
        settings = {
            ALLOW_SIGNUP = "false";
        };
    };
}
