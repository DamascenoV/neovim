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
keymap('', '<C-Left>', '<cmd>vertical resize +2<CR>') -- Resize window
keymap('', '<C-Right>', '<cmd>vertical resize -2<CR>') -- Resize window
keymap('', '<C-n>', '<cmd>NeoTreeShowToggle<CR>') -- File Tree
keymap('n', '<Up>', '<C-y>') -- Move Window Up
keymap('n', '<Down>', '<C-e>') -- Move Window Down
keymap('n', '+', '<C-a>') -- Incremente
keymap('n', '-', '<C-x>') -- Decrement
keymap('n', '<C-a>', 'gg<S-v>G') -- Select all
-- keymap("n", "<C-d>", "<C-d>zz") -- Move to the end of the line
-- keymap("n", "<C-u>", "<C-u>zz") -- Move to the start of the line
-- keymap('n', 'dw', 'vb"_d') -- Delete word backwards
keymap('n', 'x', '"_x')
keymap("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]) -- Substitute
keymap({ 'n', 'v' }, '<A-j>', ':m .+1<CR>==') -- Move line up
keymap({ 'n', 'v' }, '<A-k>', ':m .-2<CR>==') -- Move line down
keymap('n', '<leader>V', '<cmd>vsplit<CR>') -- Vertical Split
keymap('n', '<leader>H', '<cmd>split<CR>') -- Horizontal Split
keymap('v', '<', '<gv')
keymap('v', '>', '>gv')


-- Shortcut to Config
keymap('n', '<leader>Nc', '<cmd>edit ~/.config/nvim<CR>') -- Go to Neovim config


-- Buffer keymaps
keymap('n', '<tab>', '<cmd>bnext<CR>') -- Move to next buffer
keymap('n', '<S-tab>', '<cmd>bprevious<CR>') -- Move to previous buffer
keymap('n', '<leader>x', '<cmd>bdelete!<CR>') -- Close current buffer


-- Undo Tree
keymap('n', '<leader>u', '<cmd>UndotreeToggle<CR>') -- Undu Three Toogle


-- Lspsaga keymaps
keymap('n', 'mm', '<cmd>Lspsaga outline<CR>', { silent = true }) -- Outline toogle
keymap('n', 'gp', '<cmd>Lspsaga peek_definition<CR>', { silent = true }) -- Preview Definition
keymap('n', 'gh', '<cmd>Lspsaga finder<CR>', { silent = true }) -- Search references
keymap('n', 'gd', '<cmd>Lspsaga goto_definition<CR>', { silent = true }) -- Search references


-- Git DiffView
keymap('n', '<leader>go', '<cmd>DiffviewOpen<CR>', { silent = true }) -- Diff View Open
keymap('n', '<leader>gc', '<cmd>DiffviewClose<CR>', { silent = true }) -- Diff View Close


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
keymap('n', '<leader>fp', ":lua require'telescope'.extensions.project.project{}<CR>", { desc = '[F]ind [P]rojects' })


-- Diagnostic keymaps
keymap('n', '[d', vim.diagnostic.goto_prev)
keymap('n', ']d', vim.diagnostic.goto_next)
keymap('n', '<leader>e', vim.diagnostic.open_float)
keymap('n', '<leader>q', vim.diagnostic.setloclist)

-- Hop keymaps
keymap('n', '<C-t>', ':HopWord<CR>')

