{ inputs, ... }: {
    imports = [
        inputs.nocodb.nixosModules.nocodb
    ];

    services.nocodb.enable = true;
}
