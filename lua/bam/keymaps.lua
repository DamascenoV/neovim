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
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer]' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sp', ":lua require'telescope'.extensions.project.project{}<CR>", { desc = '[S]earch [P]rojects' })


-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
