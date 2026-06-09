return {
    -- Colorscheme
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("tokyonight-night")
        end,
    },
    -- Current function/class breadcrumbs
    {
        "SmiteshP/nvim-navic",
        event = "LspAttach",
        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client:supports_method("textDocument/documentSymbol") then
                        require("nvim-navic").attach(client, args.buf)
                    end
                end,
            })
        end,
    },
    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons", "SmiteshP/nvim-navic" },
        config = function()
            require("lualine").setup({
                options = { theme = "tokyonight" },
                sections = {
                    lualine_c = {
                        { "filename", path = 1 },
                        { function() return require("nvim-navic").get_location() end,
                          cond = function() return require("nvim-navic").is_available() end },
                    },
                    lualine_x = { vim.lsp.status, "encoding", "fileformat", "filetype" },
                },
            })
            vim.api.nvim_create_autocmd("LspProgress", {
                callback = function() vim.cmd.redrawstatus() end,
            })
        end,
    },
    -- File tree
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = {
            { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "File tree" },
        },
        opts = {
            filters = { dotfiles = false },
        },
    },
    -- Show pending keybinds
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = { delay = 500 },
    },
}
