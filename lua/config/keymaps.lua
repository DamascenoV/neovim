-- General keymaps
local keymap = vim.keymap.set

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Get file location "%p
keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap('i', 'jj', '<ESC>', { silent = true })
keymap('i', '<C-c>', '<ESC>', { silent = true })
keymap({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
keymap('', '<C-h>', '<C-w>h', { silent = true })                          -- Move between window
keymap('', '<C-j>', '<C-w>j', { silent = true })                          -- Move between window
keymap('', '<C-k>', '<C-w>k', { silent = true })                          -- Move between window
keymap('', '<C-l>', '<C-w>l', { silent = true })                          -- Move between window
keymap('', '<C-Up>', '<cmd>resize -2<CR>', { silent = true })             -- Resize window
keymap('', '<C-Down>', '<cmd>resize +2<CR>', { silent = true })           -- Resize window
keymap('', '<C-Left>', '<cmd>vertical resize +2<CR>', { silent = true })  -- Resize window
keymap('', '<C-Right>', '<cmd>vertical resize -2<CR>', { silent = true }) -- Resize window
keymap('', '<C-n>', '<cmd>Oil<CR>', { silent = true })                    -- Oil File system
keymap('n', '<Up>', '<C-y>', { silent = true })                           -- Move Window Up
keymap('n', '<Down>', '<C-e>', { silent = true })                         -- Move Window Down
keymap('n', '+', '<C-a>', { silent = true })                              -- Incremente
keymap('n', '-', '<C-x>', { silent = true })                              -- Decrement
keymap('n', '<C-a>', 'gg<S-v>G', { silent = true })                       -- Select all
keymap('n', 'x', '"_x', { silent = true })
keymap('n', '<leader>ee', "oif err != nil {<CR>}<Esc>Oreturn err<Esc>", { silent = true })
keymap('n', '<leader>T', '<cmd>terminal<CR>', { silent = true }) -- Open Terminal
keymap('n', '<leader>st', function()
  vim.cmd('vnew')
  vim.cmd('wincmd J')
  vim.api.nvim_win_set_height(0, 12)
  vim.cmd('term')
end
) -- Open Small Terminal
keymap('t', '<C-c>', '<C-\\><C-n>', { silent = true }) -- Normal Mode Terminal
keymap('t', '<C-q>', '<C-\\><C-d>', { silent = true }) -- Kill Terminal
keymap("n", "<leader>sr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { silent = true }) -- Substitute
keymap({ 'n', 'v' }, '<A-j>', ':m .+1<CR>==', { silent = true })                                     -- Move line up
keymap({ 'n', 'v' }, '<A-k>', ':m .-2<CR>==', { silent = true })                                     -- Move line down
keymap('n', '<leader>V', '<cmd>vsplit<CR>', { silent = true })                                       -- Vertical Split
keymap('n', '<leader>H', '<cmd>split<CR>', { silent = true })                                        -- Horizontal Split
keymap('v', '<', '<gv', { silent = true })
keymap('v', '>', '>gv', { silent = true })
keymap('v', '<C-r>', [[:s/\%V]], { silent = true }) --substitute in visual mode


-- Shortcut to Config
keymap('n', '<leader>Nc', '<cmd>e ~/.config/nvim<CR>') -- Go to Neovim config

-- Buffer keymaps
keymap('n', '<tab>', '<cmd>bnext<CR>')        -- Move to next buffer
keymap('n', '<S-tab>', '<cmd>bprevious<CR>')  -- Move to previous buffer
keymap('n', '<leader>x', '<cmd>bdelete!<CR>') -- Close current buffer


-- Undo Tree
keymap('n', '<leader>u', '<cmd>UndotreeToggle<CR>') -- Undu Three Toogle


-- See `:help telescope.builtin`
keymap('n', '<leader>?', '<cmd>Telescope oldfiles<CR>', { desc = '[?] Find recently opened files' })
keymap('n', '<leader><leader>', '<cmd>Telescope buffers<CR>', { desc = '[F]ind existing buffers' })
keymap('n', '<leader>/', '<cmd>Telescope current_buffer_fuzzy_find<CR>',
  { desc = '[/] Fuzzily search in current buffer]' })
keymap('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = '[F]ind [F]iles' })
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { desc = '[F]ind [H]elp' })
keymap('n', '<leader>fw', '<cmd>Telescope grep_string<CR>', { desc = '[Find] current [W]ord' })
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { desc = '[F]ind by [G]rep' })
keymap('n', '<leader>fd', '<cmd>Telescope diagnostics<CR>', { desc = '[F]ind [D]iagnostics' })
keymap('n', '<leader>fr', '<cmd>Telescope lsp_references<CR>', { desc = '[F]ind [R]eferences' })


-- LSP
keymap('n', 'gD', vim.lsp.buf.declaration)
keymap('n', 'gd', vim.lsp.buf.definition)
keymap('n', 'K', vim.lsp.buf.hover)
keymap('n', 'gi', vim.lsp.buf.implementation)
keymap('n', '<C-k>', vim.lsp.buf.signature_help)
keymap('n', '<space>wa', vim.lsp.buf.add_workspace_folder)
keymap('n', '<space>wr', vim.lsp.buf.remove_workspace_folder)
keymap('n', '<space>wl', function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end)
keymap('n', '<space>D', vim.lsp.buf.type_definition)
keymap('n', '<space>rn', vim.lsp.buf.rename)
keymap({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action)
keymap('n', 'gr', vim.lsp.buf.references)
keymap('n', '<space>fm', function()
  vim.lsp.buf.format { async = true }
end)


-- LSP SAGA
keymap('n', 'mm', '<cmd>Lspsaga outline<CR>', { silent = true })         -- Outline toogle
keymap('n', 'gp', '<cmd>Lspsaga peek_definition<CR>', { silent = true }) -- Preview Definition
keymap('n', 'gh', '<cmd>Lspsaga finder<CR>', { silent = true })          -- Search references


-- Diagnostic keymaps
keymap('n', '[d', vim.diagnostic.goto_prev)
keymap('n', ']d', vim.diagnostic.goto_next)
keymap('n', '<leader>e', vim.diagnostic.open_float)
keymap('n', '<leader>q', vim.diagnostic.setloclist)


-- Codeium
keymap('i', '<C-g>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
