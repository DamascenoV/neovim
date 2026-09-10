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

-- Pick
keymap({ 'n', 'v' }, ',', '<cmd>Pick commands<CR>', { desc = '[C]ommands' })
keymap('n', '<leader>gc', '<cmd>Pick git_commits<CR>', { desc = '[G]it [C]ommits' })
keymap('n', '<leader>gs', '<cmd>Pick git_hunks<CR>', { desc = '[G]it [S]tatus' })
keymap('n', '<leader>fc', '<cmd>Pick list scope="change"<CR>', { desc = '[F]ind [C]hange' })
keymap('n', '<leader>fh', '<cmd>Pick history<CR>', { desc = '[F]ind [H]istory' })
keymap('n', '<leader>fb', '<cmd>Pick buffers<CR>', { desc = '[F]ind existing buffers' })
keymap('n', '<leader>fe', '<cmd>Pick explorer<CR>', { desc = '[F]ind [E]xplorer' })
keymap('n', '<leader>ff', '<cmd>Pick files<CR>', { desc = '[F]ind [F]iles' })
keymap('n', '<leader>fg', '<cmd>Pick grep_live<CR>', { desc = '[F]ind by [G]rep' })
keymap('n', '<leader>fw', '<cmd>Pick grep<CR>', { desc = '[F]ind by [W]ord' })
keymap('n', '<leader>fW', '<cmd>Pick grep pattern="<cword>"<CR>', { desc = '[F]ind current [W]ord' })
keymap('n', '<leader>fd', '<cmd>Pick diagnostic<CR>', { desc = '[F]ind [D]iagnostics' })
keymap('n', '<leader>fD', '<cmd>Pick diagnostic scope="all"<CR>', { desc = '[F]ind [D]iagnostics All' })
keymap('n', '<leader>fr', '<cmd>Pick lsp scope="references"<CR>', { desc = '[F]ind [R]eferences' })
keymap('n', '<leader>fi', '<cmd>Pick lsp scope="implementation"<CR>', { desc = '[F]ind [I]mplementation' })
keymap('n', '<leader>f/', '<cmd>Pick history scope="/"<CR>', { desc = '[F]ind [/]' })
keymap('n', '<leader>f:', '<cmd>Pick history scope=":"<CR>', { desc = '[F]ind [:]' })
keymap('n', '<leader>/', '<cmd>Pick buf_lines<CR>', { desc = '[/] in Buffer' })
keymap('n', '<leader>fh', '<cmd>Pick git_files scope="ignored"<CR>', { desc = '[F]ind [H]idden' })
keymap('n', '<leader>fo', '<cmd>Pick oldfiles<CR>', { desc = '[F]ind recently [O]pened files' })

-- Git
keymap('n', '<leader>GD', '<cmd>Git diff<CR>', { desc = '[G]it [d]iff' })
keymap('n', '<leader>GS', '<cmd>Git status<CR>', { desc = '[G]it [S]tatus' })
keymap('n', '<leader>sc', '<cmd>lua MiniGit.show_at_cursor()<CR>', { desc = 'Git [S]how at [C]ursor' })
keymap('n', '<leader>sh', '<cmd>lua MiniGit.show_range_history()<CR>', { desc = 'Git [S]how range [H]istory' })

-- Diff
keymap('n', '<leader>go', '<cmd>lua MiniDiff.toggle_overlay()<CR>', { desc = '[G]it [O]verlay' })

-- Files
keymap('', '<C-e>', '<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>', { silent = true })
