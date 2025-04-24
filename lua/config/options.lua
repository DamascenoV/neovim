-- [[ Setting options ]]
-- See `:help vim.o`
vim.cmd('let g:netrw_liststyle = 3')

vim.opt.showmode = false
vim.g.mapleader = ' '
vim.g.maplocalleader = ','
vim.g.netrw_preview = 1
vim.opt.title = true
vim.opt.hlsearch = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.inccommand = 'split'
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.cursorline = true
vim.opt.mouse = 'a'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 1000
vim.opt.signcolumn = 'yes'
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
vim.opt.incsearch = true
vim.opt.scrolloff = 10
vim.opt.showtabline = 1
vim.opt.wildoptions = 'fuzzy'
vim.opt.completeopt = { "menuone", "noselect", "fuzzy" }
vim.opt.shortmess:append "c"
vim.opt.colorcolumn = '120'
vim.opt.clipboard = 'unnamedplus'
vim.opt.pumblend = 17
vim.opt.autoindent = true
vim.opt.cindent = true
vim.opt.showbreak = string.rep(' ', 3)
vim.opt.fillchars = { eob = '~' }
vim.opt.showmatch = true
vim.opt.list = true
vim.opt.formatoptions:remove('o')
vim.opt.listchars:append('tab:  ,trail:-')
vim.opt.laststatus = 3
vim.opt.termguicolors = true
vim.cmd.colorscheme('bamoon')

vim.o.winborder = 'rounded'
vim.o.pumheight = 10
vim.o.writebackup = false
vim.o.foldmethod = 'indent' -- Set 'indent' folding method
vim.o.foldlevel = 1 -- Display all folds except top ones
vim.o.foldnestmax = 10 -- Create folds only for some number of nested levels
vim.g.markdown_folding = 1 -- Use folding by heading in markdown files

vim.diagnostic.config({ virtual_text = true })
