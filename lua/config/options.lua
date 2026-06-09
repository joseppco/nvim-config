local opt = vim.opt

-- Indentation (matches this project's .clang-format: tabs, width 4)
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = false

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true

opt.wrap = false
opt.scrolloff = 8

opt.ignorecase = true
opt.smartcase = true

opt.splitright = true
opt.splitbelow = true

opt.termguicolors = true
opt.updatetime = 250
opt.timeoutlen = 300

opt.undofile = true

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldenable = false
opt.foldlevel = 99

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})
