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
keymap('n', '<leader>u', '<cmd>UndotreeToggle<CR>') -- Close current buffer


-- Lspsaga keymaps
keymap('n', 'mm', '<cmd>Lspsaga outline<CR>', { silent = true }) -- Outline toogle
keymap('n', 'gp', '<cmd>Lspsaga peek_definition<CR>', { silent = true }) -- Preview Definition
keymap('n', 'gh', '<cmd>Lspsaga lsp_finder<CR>', { silent = true }) -- Search references


-- Git DiffView
keymap('n', '<leader>gg', '<cmd>DiffviewFileHistory %<CR>', { silent = true }) -- Diff File
keymap('n', '<leader>gb', '<cmd>DiffviewFileHistory<CR>', { silent = true }) -- Diff Branch


-- See `:help telescope.builtin`
keymap('n', '<leader>?', '<cmd>Telescope oldfiles<CR>', { desc = '[?] Find recently opened files' })
keymap('n', '<leader><leader>', '<cmd>Telescope buffers<CR>', { desc = '[ ] Find existing buffers' })
keymap('n', '<leader>/', '<cmd>Telescope current_buffer_fuzzy_find<CR>', { desc = '[/] Fuzzily search in current buffer]' })
keymap('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = '[F]ind [F]iles' })
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { desc = '[F]ind [H]elp' })
keymap('n', '<leader>fw', '<cmd>Telescope grep_string<CR>', { desc = '[Find] current [W]ord' })
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { desc = '[F]ind by [G]rep' })
keymap('n', '<leader>fd', '<cmd>Telescope diagnostics<CR>', { desc = '[F]ind [D]iagnostics' })
keymap('n', '<leader>fp', ":lua require'telescope'.extensions.project.project{}<CR>", { desc = '[F]ind [P]rojects' })


-- Diagnostic keymaps
keymap('n', '[d', vim.diagnostic.goto_prev)
keymap('n', ']d', vim.diagnostic.goto_next)
keymap('n', '<leader>e', vim.diagnostic.open_float)
keymap('n', '<leader>q', vim.diagnostic.setloclist)


-- ChatGPT
keymap('n', '<leader>tt', '<cmd>ChatGPTEditWithInstructions<CR>', { silent = true })
keymap('n', '<Leader>tk', '<cmd>:ChatGPT<cr>', { silent = true })
keymap('n', '<Leader>tj', '<cmd>:ChatGPTActAs<cr>', { silent = true })
