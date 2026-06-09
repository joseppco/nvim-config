return {
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        opts = {
            formatters_by_ft = {
                cpp = { "clang_format" },
                c = { "clang_format" },
                h = { "clang_format" },
            },
            format_on_save = false,
        },
    },
}
