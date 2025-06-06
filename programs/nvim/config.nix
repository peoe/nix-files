{ pkgs, ... }: {
    programs.nvf = {
        enable = true;
        settings = {
            imports = [
                ./editor.nix
                ./keymaps.nix
                ./lsp.nix
                ./visuals.nix
            ];

            vim = {
                startPlugins = [ pkgs.vimPlugins.wrapping-nvim ];

                viAlias = true;
                vimAlias = true;
            };
        };
    };
}
