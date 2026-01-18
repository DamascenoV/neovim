-- [[ Setting options ]]
-- See `:help vim.o`

vim.opt.showmode = false
vim.g.mapleader = ' '
vim.g.maplocalleader = ','
vim.g.netrw_banner = 0
vim.g.netrw_preview = 1
vim.g.netrw_winsize = 24
vim.opt.title = true
vim.opt.hlsearch = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.inccommand = 'split'
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.cursorline = true
vim.opt.cursorlineopt  = 'screenline,number'
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
vim.opt.fillchars = 'eob:~'
vim.opt.showmatch = true
vim.opt.list = true
vim.opt.formatoptions:remove('o')
vim.opt.listchars:append('tab:  ,trail:-')
vim.o.splitkeep = 'topline'
vim.o.iskeyword = '@,48-57,_,192-255,-'
vim.o.ruler = false

vim.opt.termguicolors = true
-- vim.cmd.colorscheme('tama')
vim.cmd.colorscheme('orbit')

vim.o.winborder = 'bold'
vim.o.pumheight = 10
vim.o.writebackup = false

vim.diagnostic.config({ virtual_text = true })

vim.cmd('filetype plugin indent on')
if vim.fn.exists('syntax_on') then
  vim.cmd('syntax enable')
end

if vim.fn.has('nvim-0.12') == 1 then
  vim.o.pumborder = 'bold'
  require('vim._extui').enable({
    msg = { target = 'cmd' }
  })
end
