-- config
require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.lsp')

-- util
require('util.search').setup()

-- plugins
require('plugins.treesitter')
require('plugins.fugitive')
