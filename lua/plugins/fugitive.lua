vim.pack.add({ 'https://github.com/tpope/vim-fugitive' })

vim.api.nvim_set_keymap('n', '<leader>gg', '<cmd>G<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gd', '<cmd>Git diff<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gv', '<cmd>Gdiffsplit<CR>', { noremap = true, silent = true })
