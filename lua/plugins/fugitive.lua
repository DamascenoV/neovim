-- vim.pack.add({ 'https://github.com/tpope/vim-fugitive' })
--
-- vim.api.nvim_set_keymap('n', '<leader>gg', '<cmd>G<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>gd', '<cmd>Git diff<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>gv', '<cmd>Gdiffsplit<CR>', { noremap = true, silent = true })

vim.pack.add({ 'https://github.com/mistweaverco/jujutsu.nvim' })

local jj = require('jujutsu')

jj.setup({
  kind = 'split'
})

vim.keymap.set('n', '<leader>jj', function()
  jj.open()
end)

vim.keymap.set('n', '<leader>jr', function()
  jj.refresh()
end)
