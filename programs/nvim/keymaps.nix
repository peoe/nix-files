{ ... }: let
    mkNormal = {key, action, ...}: {
        mode = "n";
        key = key;
        action = action;
    };
in {
    vim.keymaps = [
        (mkNormal { key = "<leader>tt"; action = ":tabnew<cr>"; })
        {
            mode = "n";
            key = "<tab>";
            action = ":tabnext<cr>";
        }
    ];
}
