{ inputs, ... }: {
    imports = [
        inputs.nvf.homeManagerModules.default
        ./nvim/config.nix
        ./zsh/zsh.nix
    ];
}
