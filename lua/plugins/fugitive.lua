vim.pack.add({ "https://github.com/tpope/vim-fugitive" })

vim.api.nvim_set_keymap("n", "<leader>gg", "<cmd>Git<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>gd", "<cmd>Git diff<CR>", { noremap = true, silent = true })
