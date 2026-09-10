local keymap = vim.keymap.set

keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap('i', '<C-s>', vim.lsp.buf.signature_help, { silent = true })
keymap({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
keymap('', '<C-w><Up>', '<cmd>resize -2<CR>', { silent = true })
keymap('', '<C-w><Down>', '<cmd>resize +2<CR>', { silent = true })
keymap('', '<C-w><Left>', '<cmd>vertical resize +2<CR>', { silent = true })
keymap('', '<C-w><Right>', '<cmd>vertical resize -2<CR>', { silent = true })
keymap('n', '<Up>', '<C-y>', { silent = true })
keymap('n', '<Down>', '<C-e>', { silent = true })
keymap('n', '+', '<C-a>', { silent = true })
keymap('n', '-', '<C-x>', { silent = true })
keymap('n', '<C-a>', 'gg<S-v>G', { silent = true })
keymap('n', 'x', '"_x', { silent = true })
keymap('n', '<leader>T', '<cmd>terminal<CR>', { silent = true, desc = '[T]erminal' })
keymap('n', '<leader>st', function()
  vim.cmd('vnew')
  vim.cmd('wincmd J')
  vim.api.nvim_win_set_height(0, math.floor(vim.o.lines / 4))
  vim.wo.winfixheight = true
  vim.cmd('term')
end, { desc = '[S]mall [T]erminal' })
keymap('t', '<esc>', '<C-\\><C-n>', { silent = true })
keymap('t', '<C-q>', '<C-\\><C-d>', { silent = true })
keymap('n', '<leader>bt', function()
  if vim.o.background == 'dark' then
    vim.cmd('set background=light')
  else
    vim.cmd('set background=dark')
  end
end, { silent = true, desc = '[b]ackground [t]oggle' })

keymap('n', '<leader>sr', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = '[S]ubstitute [R]ename' })

keymap('n', '<leader>V', '<cmd>vnew<CR>', { silent = true, desc = 'Vertical Split' })
keymap('n', '<leader>H', '<cmd>split_f<CR>', { silent = true, desc = 'Horizontal Split' })
keymap('v', '<', '<gv', { silent = true })
keymap('v', '>', '>gv', { silent = true })

keymap('n', '<leader>Nc', '<cmd>e ~/.config/nvim<CR>', { desc = '[N]eovim [c]onfig' })
keymap('n', '<leader>pu', vim.pack.update, { desc = '[P]ack [U]pdate' })
