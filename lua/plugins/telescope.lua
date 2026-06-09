return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            "nvim-telescope/telescope-ui-select.nvim",
        },
        config = function()
            local telescope = require("telescope")
            local builtin = require("telescope.builtin")

            telescope.setup({
                defaults = {
                    file_ignore_patterns = { "build/", "%.o", "%.a", "%.so" },
                },
                extensions = {
                    ["ui-select"] = require("telescope.themes").get_dropdown(),
                },
            })
            telescope.load_extension("fzf")
            telescope.load_extension("ui-select")

            local map = vim.keymap.set
            map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
            map("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
            map("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
            map("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
            map("n", "<leader>fS", builtin.lsp_workspace_symbols, { desc = "Workspace symbols" })

            -- LSP via Telescope
            map("n", "gr", builtin.lsp_references, { desc = "References" })
            map("n", "gd", builtin.lsp_definitions, { desc = "Go to definition" })
        end,
    },
}
