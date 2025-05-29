{
    vim = {
        highlight = {
            CursorLine = { bg = "#363636"; };
            LineNrAbove = { fg = "#0db9d7"; };
            LineNrBelow = { fg = "#9ece6a"; };
            LineNr = { fg = "#ff9e64"; bold = true; };
        };

        options = {
            cursorlineopt = "both";

            number = true;
            relativenumber = true;

            showtabline = 1;

            title = true;
            titlestring = "%t - nvim";

            cmdheight = 0;
        };

        theme = {
            name = "tokyonight";
            style = "storm";
            enable = true;
        };

        visuals.nvim-cursorline = {
            setupOpts = {
                cursorline = {
                    timeout = 0;
                    enable = true;
                };
                cursorword.enable = false;
            };
            enable = true;
        };
    };
}
