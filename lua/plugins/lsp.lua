return {
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        opts = {},
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = { "clangd" },
        },
    },
    {
        "hrsh7th/cmp-nvim-lsp",
        lazy = true,
    },
}
