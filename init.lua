-- config
require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.lsp')

-- plugins
require('plugins.treesitter')
require('plugins.fugitive')

-- custom
require('util.compile')
