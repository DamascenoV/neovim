vim.pack.add({ 'https://github.com/NeogitOrg/neogit' })

require('neogit').setup({
  kind = 'replace',
  auto_close_console = false
})

vim.api.nvim_set_keymap('n', '<leader>gg', '<cmd>Neogit<CR>', { noremap = true, silent = true })
