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
vim.o.tabstop = 4
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
vim.opt.autoindent = true
vim.opt.cindent = true
vim.opt.showbreak = string.rep(" ", 3)
vim.opt.fillchars = { eob = "~" }
vim.opt.showmatch = true
vim.opt.list = true
vim.opt.listchars:append "tab:  ,trail:-"
--vim.opt.listchars:append "tab:  ,trail:-,eol:↲"
vim.opt.laststatus = 3

-- Set colorscheme
vim.o.termguicolors = true
vim.cmd [[
  tnoremap <Esc> <C-\\><C-n>
  set completeopt=menuone,noinsert,noselect
  highlight! default link CmpItemKind CmpItemMenuDefault
  ]]

--vim.lsp.inlay_hint.enable(0, true)
