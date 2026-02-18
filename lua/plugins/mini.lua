local later = MiniDeps.later

later(function() require('mini.ai').setup() end)
later(function() require('mini.surround').setup() end)
later(function() require('mini.diff').setup() end)
later(function() require('mini.cmdline').setup({ autopeek = { enable = false } }) end)
later(function() require('mini.git').setup({ command = { split = 'horizontal' } }) end)
