{ nixpkgs, nvf, pkgs, self, ... }: {
    packages.x86_64-linux.my-neovim = (
        nvf.lib.neovimConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [ ./nvim/config.nix ];
        }
    ).neovim;

    home.packages = with pkgs; [
        btop
    ] ++ [
        self.packages.${pkgs.stdenv.system}.neovim
    ];
}
