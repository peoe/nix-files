{
    description = "NixOS server ISO";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

        proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
    };

    outputs = { self, nixpkgs, proxmox-nixos, ... }: let
        vars = import ./vars.nix;
    in {
        nixosConfigurations = {
            nixiso = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    (nixpkgs + "nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
                    ./hosts/iso.nix
                ];
            };
            nixserver = nixpkgs.lib.nixosSystem rec {
                system = "x86_64-linux";
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
                    ./hosts/nixserver.iso
                ];
            };
        };
    };
}
