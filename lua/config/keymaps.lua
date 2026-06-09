vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- Window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Better indenting in visual mode
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Save
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
map("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Save file" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Quickfix navigation (useful for build errors)
map("n", "]q", "<cmd>cnext<CR>")
map("n", "[q", "<cmd>cprev<CR>")

-- LSP (defined here as fallbacks; overridden by lspconfig on attach)
map("n", "K", vim.lsp.buf.hover, { desc = "Hover docs" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "References" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>ls", "<cmd>lua vim.print(vim.lsp.status())<CR>", { desc = "LSP status" })

-- Search word under cursor in all files
map("n", "<leader>*", function() require("telescope.builtin").grep_string() end, { desc = "Grep word under cursor" })

-- Buffer navigation
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprev<CR>", { desc = "Prev buffer" })

-- Switch between header and implementation
map("n", "<leader>h", function()
    vim.lsp.buf_request(0, "textDocument/switchSourceHeader", { uri = vim.uri_from_bufnr(0) }, function(err, result)
        if err or not result then return end
        vim.cmd("edit " .. vim.uri_to_fname(result))
    end)
end, { desc = "Switch header/source" })
