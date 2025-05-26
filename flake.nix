{
    description = "NixOS server ISO";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        impermanence.url = "github:nix-community/impermanence";
        proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";

        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, proxmox-nixos, ... } @ inputs: let
        inherit (self) outputs;
        vars = import ./vars.nix;
    in {
        nixosConfigurations = {
            nixiso = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = {inherit inputs outputs vars;};
                modules = [
                    (nixpkgs + "nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
                    ./hosts/iso.nix
                ];
            };
            nixserver = nixpkgs.lib.nixosSystem rec {
                system = "x86_64-linux";
                specialArgs = {inherit inputs outputs vars;};
                modules = [
                    ({ pkgs, lib, ... }: {
                        services.proxmox-ve = {
                            enable = true;
                            ipAddress = "192.168.0.1";
                        };

                        nixpkgs.overlays = [
                            proxmox-nixos.overlays.${system}
                        ];
                    })

                    proxmox-nixos.nixosModules.proxmox-ve
                    ./hosts/nixserver/config.nix
                ];
            };
        };
    };
}
