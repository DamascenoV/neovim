-- General keymaps
local keymap = vim.keymap.set

-- Get file location "%p
keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap('i', '<C-s>', function() vim.lsp.buf.signature_help() end, { silent = true })
keymap({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
keymap('', '<C-h>', '<C-w>h', { silent = true }) -- Move between window
keymap('', '<C-j>', '<C-w>j', { silent = true }) -- Move between window
keymap('', '<C-k>', '<C-w>k', { silent = true }) -- Move between window
keymap('', '<C-l>', '<C-w>l', { silent = true }) -- Move between window
keymap('', '<C-w><C-Up>', '<cmd>resize -2<CR>', { silent = true }) -- Resize window
keymap('', '<C-w><C-Down>', '<cmd>resize +2<CR>', { silent = true }) -- Resize window
keymap('', '<C-w><C-Left>', '<cmd>vertical resize +2<CR>', { silent = true }) -- Resize window
keymap('', '<C-w><C-Right>', '<cmd>vertical resize -2<CR>', { silent = true }) -- Resize window
keymap('', '<C-e>', function() require('mini.files').open(vim.api.nvim_buf_get_name(0)) end, { silent = true }) -- File Explorer
keymap('n', '<Up>', '<C-y>', { silent = true }) -- Move Window Up
keymap('n', '<Down>', '<C-e>', { silent = true }) -- Move Window Down
keymap('n', '+', '<C-a>', { silent = true }) -- Incremente
keymap('n', '-', '<C-x>', { silent = true }) -- Decrement
keymap('n', '<C-a>', 'gg<S-v>G', { silent = true }) -- Select all
keymap('n', 'x', '"_x', { silent = true })
keymap('n', '<leader>T', '<cmd>terminal<CR>', { silent = true, desc = '[T]erminal' }) -- Open Terminal
keymap('n', '<leader>st', function()
  vim.cmd('vnew')
  vim.cmd('wincmd J')
  vim.api.nvim_win_set_height(0, 12)
  vim.wo.winfixheight = true
  vim.cmd('term')
end, { desc = '[S]mall [T]erminal' }) -- Open Small Terminal
keymap('t', '<C-c>', '<C-\\><C-n>', { silent = true }) -- Normal Mode Terminal
keymap('t', '<C-q>', '<C-\\><C-d>', { silent = true }) -- Kill Terminal
keymap('n', '<leader>bt', function ()
  if vim.o.background == "dark" then
    vim.cmd('set background=light')
  else
    vim.cmd('set background=dark')
  end
end, { silent = true, desc = '[b]ackground [t]oggle'} ) -- Toggle background color

keymap('n', '<leader>sr', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = '[S]ubstitute [R]ename'}) -- Substitute

-- Move line up
keymap('n', '<leader>V', '<cmd>vnew<CR>', { silent = true, desc = 'Vertical Split' }) -- Vertical Split
keymap('n', '<leader>H', '<cmd>split_f<CR>', { silent = true, desc = 'Horizontal Split' }) -- Horizontal Split
keymap('v', '<', '<gv', { silent = true })
keymap('v', '>', '>gv', { silent = true })

-- Shortcut to Config
keymap('n', '<leader>Nc', '<cmd>e ~/.config/nvim<CR>', { desc = '[N]eovim [c]onfig' } ) -- Go to Neovim config

-- Buffer keymaps
-- keymap('n', '<tab>', '<cmd>bnext<CR>') -- Move to next buffer
-- keymap('n', '<S-tab>', '<cmd>bprevious<CR>') -- Move to previous buffer
keymap('n', '<leader>x', '<cmd>bdelete!<CR>', { desc = 'Close Buffer' }) -- Close current buffer

-- Pick
keymap('n', '<leader>gc', '<cmd>Pick git_commits<CR>', { desc = '[G]it [C]ommits' })
keymap('n', '<leader>gs', '<cmd>Pick git_hunks<CR>', { desc = '[G]it [S]tatus' })
keymap('n', '<leader>fc', '<cmd>Pick list scope="change"<CR>', { desc = '[F]ind [C]hange' })
keymap('n', '<leader>fb', '<cmd>Pick buffers<CR>', { desc = '[F]ind existing buffers' })
keymap('n', '<leader>fe', '<cmd>Pick explorer<CR>', { desc = '[F]ind [E]xplorer' })
keymap('n', '<leader>ff', '<cmd>Pick files<CR>', { desc = '[F]ind [F]iles' })
keymap('n', '<leader>fw', '<cmd>Pick grep<CR>', { desc = '[Find] current [W]ord' })
keymap('n', '<leader>fW', '<cmd>Pick grep pattern="<cword>"<CR>', { desc = '[Find] current [W]ord' })
keymap('n', '<leader>fg', '<cmd>Pick grep_live<CR>', { desc = '[F]ind by [G]rep' })
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
keymap('n', '<leader>sc', '<cmd>lua MiniGit.show_at_cursor()<CR>', { desc = 'Git [S]how at [C]ursor' })
keymap('n', '<leader>sh', '<cmd>lua MiniGit.show_range_history()<CR>', { desc = 'Git [S]how range [H]istory' })

-- Diff
keymap('n', '<leader>go', '<cmd>lua MiniDiff.toggle_overlay()<CR>', { desc = '[G]it [O]verlay' })

-- LSP
keymap('n', 'gD', vim.lsp.buf.declaration)
keymap('n', 'gd', vim.lsp.buf.definition)
keymap('n', 'K', vim.lsp.buf.hover)
keymap('n', 'gi', vim.lsp.buf.implementation)
keymap('n', '<space>K', vim.lsp.buf.signature_help, { desc = 'Signature' })
keymap('n', '<space>wa', vim.lsp.buf.add_workspace_folder)
keymap('n', '<space>wr', vim.lsp.buf.remove_workspace_folder)
keymap('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end)
keymap('n', '<space>td', vim.lsp.buf.type_definition, { desc = '[T]ype [D]efinition' })
keymap({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, { desc = '[C]ode [A]ction' })
keymap('n', 'gr', vim.lsp.buf.references)
keymap('n', '<space>fm', function() vim.lsp.buf.format({ async = true }) end, { desc = '[F]ormat' })

-- Diagnostic keymaps
keymap('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open Float Diagnostic' })
keymap('n', '<leader>q', vim.diagnostic.setloclist, { desc = '[Q]uick List Diagnostic' })
