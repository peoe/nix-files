{ pkgs, ... }: {
    vim = {
        lazy.plugins = {
            "wrapping.nvim" = {
                package = pkgs.vimPlugins.wrapping-nvim;
                setupModule = "wrapping";
            };
        };

        options = {
            tabstop = 4;
            softtabstop = 4;
            shiftwidth = 4;

            expandtab = true;
            smartindent = true;

            scrolloff = 7;
            sidescrolloff = 7;

            clipboard = ""; # clipboard = "";

            ignorecase = true;
            # incsearch = true; # this should only be set when really needed

            # to get this working look at https://nixos.wiki/wiki/Vim
            # spell = true;
            # spellfile = "~/.nvim/spellfile";
            # spelllang = "en_gb,de,fr";

            wrap = false;
            linebreak = true;
            breakindent = true;

            # # disable netrw
            # loaded_netrw = 1;
            # loaded_netrwPlugin = 1;

            whichwrap = "b,s,<,>,[,]";
        };
    };
}
