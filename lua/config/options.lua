-- [[ Setting options ]]
-- See `:help vim.o`

vim.cmd([[
  let g:did_install_default_menus = 1
]])

vim.g.mapleader = ' '
vim.g.maplocalleader = ','
vim.g.netrw_banner = 0
vim.g.netrw_preview = 1
-- vim.g.netrw_winsize = 24
vim.opt.showmode = false
vim.opt.title = true
vim.opt.hlsearch = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.inccommand = 'split'
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = 'screenline,number'
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
vim.opt.tabclose = 'uselast'
vim.opt.wildoptions = 'fuzzy'
vim.opt.wildmode = 'list:longest'
vim.opt.wildignore = '.git,.6'
vim.opt.completeopt = { 'menuone', 'noselect', 'noinsert', 'fuzzy', 'popup' }
vim.opt.complete:append('f,kspell')
vim.opt.shortmess:append('c')
vim.opt.colorcolumn = '120'
vim.opt.clipboard = 'unnamedplus'
vim.opt.pumblend = 17
vim.opt.autoindent = true
vim.opt.cindent = true
vim.opt.showbreak = string.rep(' ', 3)
vim.opt.showmatch = true
vim.opt.list = true
vim.opt.formatoptions:remove('o')
vim.opt.listchars:append('tab:  ,trail:-')
vim.opt.fillchars = 'msgsep:-,eob:~,stl:—,stlnc:—'
vim.opt.jumpoptions:append('view')
vim.opt.cpoptions:remove('_')
vim.o.splitkeep = 'topline'
vim.o.iskeyword = '@,48-57,_,192-255,-'
vim.o.ruler = false
vim.o.cmdheight = 0

function _G.diagnostic_status()
  local counts = vim.diagnostic.count(0)

  local errors = counts[vim.diagnostic.severity.ERROR] or 0
  local warns = counts[vim.diagnostic.severity.WARN] or 0
  local hint = counts[vim.diagnostic.severity.HINT] or 0

  return table.concat({
    '[',
    '%#DiagnosticError#',
    tostring(errors),
    '%*, ',
    '%#DiagnosticWarn#',
    tostring(warns),
    '%*, ',
    '%#DiagnosticInfo#',
    tostring(hint),
    '%*]',
  })
end

vim.opt.grepprg = 'rg --vimgrep --smart-case --hidden --glob "!.git"'
vim.opt.grepformat = '%f:%l:%c:%m'

vim.opt.termguicolors = true
vim.cmd.colorscheme('tama')

vim.o.pumheight = 10
vim.o.writebackup = false

vim.diagnostic.config({ virtual_text = true })

vim.cmd('filetype plugin indent on')

-- vim.o.pumborder = 'bold'
require('vim._core.ui2').enable({
  msg = { target = 'cmd' },
})
