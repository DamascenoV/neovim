-- [[ Setting options ]]
-- See `:help vim.o`
vim.o.guifont = 'JetBrainsMono Nerd Font Mono:h8'
vim.opt.title = true
vim.o.hlsearch = false
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.cursorline = true
vim.o.cursorlineopt = 'number'
vim.o.mouse = 'a'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 1000
vim.wo.signcolumn = 'yes'
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.wrap = true
vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.o.incsearch = true
vim.o.scrolloff = 10
vim.o.completeopt = 'menuone,noinsert,noselect'
vim.o.colorcolumn = '120'
vim.opt.clipboard = 'unnamedplus'
vim.opt.pumblend = 17
vim.opt.wildmode = 'longest:full'
vim.opt.wildoptions = 'pum'
vim.opt.autoindent = true
vim.opt.cindent = true
vim.opt.showbreak = string.rep(" ", 3)
vim.opt.fillchars = { eob = "~" }
vim.opt.undofile = true
vim.opt.signcolumn = 'yes'
vim.opt.showmatch = true
vim.opt.list = true
vim.opt.listchars:append "tab:  ,trail:-"
vim.opt.laststatus = 3

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Go To Normal mode
vim.keymap.set('i', 'jj', '<ESC>', { silent = true })

-- Set colorscheme
vim.o.termguicolors = true
vim.cmd [[
  tnoremap <Esc> <C-\\><C-n>
  set completeopt=menuone,noinsert,noselect
  highlight! default link CmpItemKind CmpItemMenuDefault
  ]]

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

local group
vim.api.nvim_create_augroup("CursorLineControl", { clear = true })
local set_cursor_line = function(event, value, pattern)
  vim.api.nvim_create_autocmd(event, {
    group = group,
    pattern = pattern,
    callback = function()
      vim.opt_local.cursorline = value
    end,
  })
end

vim.api.nvim_command("autocmd TermOpen * startinsert")             -- starts in insert mode
vim.api.nvim_command("autocmd TermOpen * setlocal nonumber norelativenumber")       -- no numbers
vim.api.nvim_command("autocmd TermEnter * setlocal signcolumn=no") -- no sign column

set_cursor_line('WinLeave', false)
set_cursor_line("WinEnter", true)
set_cursor_line('FileType', false, 'TelescopePrompt')
