{
    description = "NixOS server ISO";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        # impermanence.url = "github:nix-community/impermanence";
        nvf.url = "github:notashelf/nvf";

        disko = {
            url = "github:nix-community/disko/latest";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        home-manager = {
            url = "github:nix-community/home-manager/release-25.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, disko, ... } @ inputs: let
        inherit (self) outputs;
        vars = import ./vars.nix;
    in {
        nixosConfigurations = {
            nixiso = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = {inherit inputs outputs vars;};
                modules = [
                    ({ pkgs, modulesPath, ... }: {
                        imports = [
                            (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
                            ./hosts/iso.nix
                        ];
                    })
                ];
            };
            nixserver = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = {inherit inputs outputs vars;};
                modules = [
                    disko.nixosModules.disko
                    ./hosts/nixserver/config.nix
                ];
            };
        };
    };
}
