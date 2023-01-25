-- General keymaps
local keymap = vim.keymap.set
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
keymap('', '<C-h>', '<C-w>h') -- Move between window
keymap('', '<C-j>', '<C-w>j') -- Move between window
keymap('', '<C-k>', '<C-w>k') -- Move between window
keymap('', '<C-l>', '<C-w>l') -- Move between window
keymap('', '<C-Up>', '<cmd>resize -2<CR>') -- Resize window
keymap('', '<C-Down>', '<cmd>resize +2<CR>') -- Resize window
keymap('', '<C-Left>', '<cmd>vertical resize -2<CR>') -- Resize window
keymap('', '<C-Right>', '<cmd>vertical resize +2<CR>') -- Resize window
keymap('', '<C-e>', '<cmd>NeoTreeShowToggle<CR>') -- File Tree
keymap('n', '+', '<C-a>') -- Incremente
keymap('n', '-', '<C-x>') -- Decrement
keymap('n', '<C-a>', 'gg<S-v>G') -- Select all
keymap('n', 'dw', 'vb"_d') -- Delete word backwards
keymap('n', 'x', '"_x')
keymap({'n', 'v' }, '<A-j>', ':m .+1<CR>==') -- Move line up
keymap({'n', 'v' }, '<A-k>', ':m .-2<CR>==') -- Move line down
keymap('v', '<', '<gv')
keymap('v', '>', '>gv')
keymap('n', '<leader>Nc', '<cmd>edit ~/.config/nvim/init.lua<CR>') -- Go to Neovim config


-- Buffer keymaps
keymap('n', '<tab>', '<cmd>bnext<CR>') -- Move to next buffer
keymap('n', '<S-tab>', '<cmd>bprevious<CR>') -- Move to previous buffer
keymap('n', '<leader>x', '<cmd>bdelete<CR>') -- Close current buffer


-- Undo Tree
vim.keymap.set('n', '<leader>u', '<cmd>UndotreeToggle<CR>') -- Close current buffer


-- Lspsaga keymaps
vim.keymap.set('n', 'mm', '<cmd>Lspsaga outline<CR>', { silent = true }) -- Outline toogle
vim.keymap.set('n', 'gp', '<cmd>Lspsaga peek_definition<CR>', { silent = true }) -- Preview Definition
vim.keymap.set('n', 'gh', '<cmd>Lspsaga lsp_finder<CR>', { silent = true }) -- Search references


-- Git DiffView
vim.keymap.set('n', '<leader>gg', '<cmd>DiffviewFileHistory %<CR>', { silent = true }) -- Diff File
vim.keymap.set('n', '<leader>gb', '<cmd>DiffviewFileHistory<CR>', { silent = true }) -- Diff Branch


-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', '<cmd>Telescope oldfiles<CR>', { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><leader>', '<cmd>Telescope buffers<CR>', { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', '<cmd>Telescope current_buffer_fuzzy_find<CR>', { desc = '[/] Fuzzily search in current buffer]' })
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { desc = '[F]ind [H]elp' })
vim.keymap.set('n', '<leader>fw', '<cmd>Telescope grep_string<CR>', { desc = '[Find] current [W]ord' })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { desc = '[F]ind by [G]rep' })
vim.keymap.set('n', '<leader>fd', '<cmd>Telescope diagnostics<CR>', { desc = '[F]ind [D]iagnostics' })
vim.keymap.set('n', '<leader>fp', ":lua require'telescope'.extensions.project.project{}<CR>", { desc = '[F]ind [P]rojects' })


-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
