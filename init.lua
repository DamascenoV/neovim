-- config
require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.lsp')

-- util
require('util.search').setup()
require('util.picker').setup()
require('util.vcs').setup()

-- plugins
require('plugins.treesitter')
