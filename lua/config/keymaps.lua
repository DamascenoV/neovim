local keymap = vim.keymap.set
keymap('i', '<C-s>', function() vim.lsp.buf.signature_help() end, { silent = true })
keymap({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
keymap('', '<C-w><Up>', '<cmd>resize -2<CR>', { silent = true }) -- Resize window
keymap('', '<C-w><Down>', '<cmd>resize +2<CR>', { silent = true }) -- Resize window
keymap('', '<C-w><Left>', '<cmd>vertical resize +2<CR>', { silent = true }) -- Resize window
keymap('', '<C-w><Right>', '<cmd>vertical resize -2<CR>', { silent = true }) -- Resize window
keymap('n', '<Up>', '<C-y>', { silent = true }) -- Move Window Up
keymap('n', '<Down>', '<C-e>', { silent = true }) -- Move Window Down
keymap('n', '+', '<C-a>', { silent = true }) -- Incremente
keymap('n', '-', '<C-x>', { silent = true }) -- Decrement
keymap('n', '<C-a>', 'gg<S-v>G', { silent = true }) -- Select all
keymap('n', 'x', '"_x', { silent = true })
keymap('n', '<leader>T', '<cmd>terminal<CR>', { silent = true, desc = '[T]erminal' }) -- Open Terminal
keymap('t', '<esc>', '<C-\\><C-n>', { silent = true }) -- Normal Mode Terminal
keymap('t', '<C-q>', '<C-\\><C-d>', { silent = true }) -- Kill Terminal
keymap('n', '<leader>V', '<cmd>vnew<CR>', { silent = true, desc = 'Vertical Split' }) -- Vertical Split
keymap('n', '<leader>H', '<cmd>split_f<CR>', { silent = true, desc = 'Horizontal Split' }) -- Horizontal Split
keymap('v', '<', '<gv', { silent = true })
keymap('v', '>', '>gv', { silent = true })
keymap('n', '<C-e>', '<cmd>Sex!<CR>', { desc = 'FileTree' })
keymap('n', '<leader>ff', ':find ', { desc = 'Find files' })
keymap('n', '<leader>fb', ':b ', { desc = 'Find Buffer' })
keymap('n', '<leader>sg', ':Rg ', { desc = 'Find pattern' })
keymap('n', '<leader>x', '<cmd>bdelete!<CR>', { desc = 'Close Buffer' }) -- Close current buffer
keymap('n', '<leader>GD', '<cmd>Git diff<CR>', { desc = '[G]it [d]iff' })
keymap('n', '<leader>GS', '<cmd>Git status<CR>', { desc = '[G]it [S]tatus' })
keymap('n', '<leader>sc', '<cmd>lua MiniGit.show_at_cursor()<CR>', { desc = 'Git [S]how at [C]ursor' })
keymap('n', '<leader>sh', '<cmd>lua MiniGit.show_range_history()<CR>', { desc = 'Git [S]how range [H]istory' })
keymap('n', '<leader>go', '<cmd>lua MiniDiff.toggle_overlay()<CR>', { desc = '[G]it [O]verlay' })
keymap('n', 'gD', vim.lsp.buf.declaration)
keymap('n', 'gd', vim.lsp.buf.definition)
keymap('n', 'K', vim.lsp.buf.hover)
keymap('n', 'gi', vim.lsp.buf.implementation)
keymap('n', '<leader>rn', vim.lsp.buf.rename)
keymap('n', '<space>K', vim.lsp.buf.signature_help, { desc = 'Signature' })
keymap('n', '<space>wa', vim.lsp.buf.add_workspace_folder)
keymap('n', '<space>wr', vim.lsp.buf.remove_workspace_folder)
keymap('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end)
keymap('n', '<space>td', vim.lsp.buf.type_definition, { desc = '[T]ype [D]efinition' })
keymap({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, { desc = '[C]ode [A]ction' })
keymap('n', 'gr', vim.lsp.buf.references)
keymap('n', '<space>fm', function() vim.lsp.buf.format({ async = true }) end, { desc = '[F]ormat' })
keymap('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open Float Diagnostic' })
keymap('n', '<leader>q', vim.diagnostic.setloclist, { desc = '[Q]uick List Diagnostic' })
