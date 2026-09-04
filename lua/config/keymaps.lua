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

keymap('n', '<leader>x', '<cmd>bdelete!<CR>', { desc = 'Close Buffer' })

keymap('n', '<leader>cp', ':Compile ', { desc = '[C]ompile' })

keymap('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open Float Diagnostic' })
keymap('n', '<leader>q', '<cmd>copen<CR>', { desc = '[Q]uick List Diagnostic' })
keymap('n', '<leader>Q', function()
  vim.diagnostic.setqflist({ title = 'Project Diagnostics' })
  vim.cmd('botright copen')
end, { desc = 'Project [Q]uick Diagnostics' })
keymap('n', '<leader>s', '<cmd>cwindow<CR>', { desc = '[Q]uick List' })
keymap('n', '<leader>fg', ':Grep ', { desc = '[F]ind [G]rep' })
keymap('n', '<leader>pu', vim.pack.update, { desc = '[P]ack [U]pdate' })

-- Picker & explorer (native, bottom splits)
keymap({ 'n', 'v' }, ',', '<cmd>Pick commands<CR>', { desc = '[C]ommands' })
keymap('n', '<leader>gg', function() require('util.vcs').open() end, { desc = '[G]it/jj panel' })
keymap('n', '<leader>gc', '<cmd>Pick git_commits<CR>', { desc = '[G]it [C]ommits' })
keymap('n', '<leader>gs', '<cmd>Pick git_status<CR>', { desc = '[G]it [S]tatus' })
keymap('n', '<leader>fc', '<cmd>Pick git_hunks<CR>', { desc = '[F]ind [C]hanges' })
keymap('n', '<leader>fb', '<cmd>Pick buffers<CR>', { desc = '[F]ind existing buffers' })
keymap('n', '<leader>fe', function() require('util.explorer').open() end, { desc = '[F]ile [E]xplorer' })
keymap('n', '<leader>ff', '<cmd>Pick files<CR>', { desc = '[F]ind [F]iles' })
keymap('n', '<leader>fh', '<cmd>Pick hidden<CR>', { desc = '[F]ind [H]idden' })
keymap('n', '<leader>fH', '<cmd>Pick history_search<CR>', { desc = '[F]ind search [H]istory' })
keymap('n', '<leader>f:', '<cmd>Pick history_cmd<CR>', { desc = '[F]ind command history' })
keymap(
  'n',
  '<leader>sw',
  function() require('util.picker_sources').get('grep').start({ query = vim.fn.expand('<cword>') }) end,
  { desc = '[S]earch current [W]ord' }
)
keymap('n', '<leader>sg', '<cmd>Pick grep<CR>', { desc = '[S]earch by [G]rep' })
keymap('n', '<leader>fd', '<cmd>Pick diagnostic<CR>', { desc = '[F]ind [D]iagnostics' })
keymap('n', '<leader>fD', '<cmd>Pick diagnostic all<CR>', { desc = '[F]ind [D]iagnostics All' })
keymap('n', '<leader>fr', '<cmd>Pick lsp references<CR>', { desc = '[F]ind [R]eferences' })
keymap('n', '<leader>fi', '<cmd>Pick lsp implementation<CR>', { desc = '[F]ind [I]mplementation' })
keymap('n', '<leader>/', '<cmd>Pick buf_lines<CR>', { desc = '[/] in Buffer' })
keymap('n', '<leader>fo', '<cmd>Pick oldfiles<CR>', { desc = '[F]ind recently [O]pened files' })
keymap(
  'n',
  '<C-e>',
  function() require('util.explorer').open(vim.api.nvim_buf_get_name(0)) end,
  { silent = true, desc = 'File explorer at current file' }
)
