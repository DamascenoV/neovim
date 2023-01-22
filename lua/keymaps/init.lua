-- General keymaps
vim.keymap.set('', '<C-h>', '<C-w>h') -- Move between window
vim.keymap.set('', '<C-j>', '<C-w>j') -- Move between window
vim.keymap.set('', '<C-k>', '<C-w>k') -- Move between window
vim.keymap.set('', '<C-l>', '<C-w>l') -- Move between window
vim.keymap.set('', '<C-Up>', '<cmd>resize -2<CR>') -- Resize window
vim.keymap.set('', '<C-Down>', '<cmd>resize +2<CR>') -- Resize window
vim.keymap.set('', '<C-Left>', '<cmd>vertical resize -2<CR>') -- Resize window
vim.keymap.set('', '<C-Right>', '<cmd>vertical resize +2<CR>') -- Resize window
vim.keymap.set('', '<C-e>', '<cmd>NeoTreeShowToggle<CR>') -- File Tree
vim.keymap.set('n', '+', '<C-a>') -- Incremente
vim.keymap.set('n', '-', '<C-x>') -- Decrement
vim.keymap.set('n', '<C-a>', 'gg<S-v>G') -- Select all
vim.keymap.set('n', 'dw', 'vb"_d') -- Delete word backwards
vim.keymap.set('n', 'x', '"_x')
vim.keymap.set({'n', 'v' }, '<A-j>', ':m .+1<CR>==') -- Move line up
vim.keymap.set({'n', 'v' }, '<A-k>', ':m .-2<CR>==') -- Move line down
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')
vim.keymap.set('n', '<leader>Nc', '<cmd>edit ~/.config/nvim/init.lua<CR>') -- Go to Neovim config


-- Buffer keymaps
vim.keymap.set('n', '<tab>', '<cmd>bnext<CR>') -- Move to next buffer
vim.keymap.set('n', '<S-tab>', '<cmd>bprevious<CR>') -- Move to previous buffer
vim.keymap.set('n', '<leader>x', '<cmd>bdelete<CR>') -- Close current buffer


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

