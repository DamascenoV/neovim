local later = Config.now
local helper = require('util.mini_helper')

later(function() require('mini.ai').setup() end)
later(function() require('mini.align').setup() end)
later(function() require('mini.surround').setup() end)
later(function() require('mini.diff').setup() end)
later(function() require('mini.jump').setup() end)
later(function() require('mini.bufremove').setup() end)
later(function() require('mini.operators').setup() end)
later(function() require('mini.pairs').setup() end)
later(function() require('mini.splitjoin').setup() end)

later(function()
  require('mini.move').setup({
    mappings = {
      left = '<left>',
      right = '<right>',
      down = '<down>',
      up = '<up>',
      line_left = '<left>',
      line_right = '<right>',
      line_down = '<down>',
      line_up = '<up>',
    },
  })
end)

later(function()
  require('mini.git').setup({
    command = {
      split = 'horizontal'
    }
  })
end)

later(function()
  local mini_indentscope = require('mini.indentscope')
  mini_indentscope.setup({
    draw = {
      delay = 0,
      animation = mini_indentscope.gen_animation.none()
    },
    symbol = '│',
    options = { try_as_border = true },
  })
end)

later(function()
  local mini_pick = require('mini.pick')
  mini_pick.setup({
    window = {
      config = helper.win_config,
    },
    options = {
      content_from_bottom = true
    },
    mappings = {
      delete_buffer = {
        char = '<C-d>',
        func = function()
          local matches = mini_pick.get_picker_matches()
          if not matches or not matches.current.bufnr then return end

          local buf_id = matches.current.bufnr
          if require('mini.bufremove').delete(buf_id) then
            local items = vim.tbl_filter(
              function(item) return item.bufnr ~= buf_id end,
              mini_pick.get_picker_items() or {}
            )
            mini_pick.set_picker_items(items)
          end
        end,
      },
      choose_marked = '<C-q>'
    },
  })
  vim.ui.select = mini_pick.ui_select
end)

later(function() require('mini.extra').setup() end)

later(function()
  require('mini.files').setup({
    content = {
      prefix = helper.ls_prefix
    },
    mappings = {
      close = '<C-c>',
      go_in = 'L',
      go_in_plus = '<CR>',
      go_out = 'H',
      go_out_plus = '-',
      synchronize = '<C-y>'
    },
    options = {
      use_as_default_explorer = false
    },
  })
end)

later(function()
  local hipatterns = require('mini.hipatterns')
  hipatterns.setup({
    highlighters = {
      fixme     = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
      hack      = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
      todo      = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
      note      = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },

      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

-- Mini keymaps
local keymap = vim.keymap.set

-- Pick
keymap({ 'n', 'v' }, ',', '<cmd>Pick commands<CR>', { desc = '[C]ommands' })
keymap('n', '<leader>gc', '<cmd>Pick git_commits<CR>', { desc = '[G]it [C]ommits' })
keymap('n', '<leader>gs', '<cmd>Pick git_hunks<CR>', { desc = '[G]it [S]tatus' })
keymap('n', '<leader>fc', '<cmd>Pick list scope="change"<CR>', { desc = '[F]ind [C]hange' })
keymap('n', '<leader>fh', '<cmd>Pick history<CR>', { desc = '[F]ind [H]istory' })
keymap('n', '<leader>fb', '<cmd>Pick buffers<CR>', { desc = '[F]ind existing buffers' })
keymap('n', '<leader>fe', '<cmd>Pick explorer<CR>', { desc = '[F]ind [E]xplorer' })
keymap('n', '<leader>ff', '<cmd>Pick files<CR>', { desc = '[F]ind [F]iles' })
keymap('n', '<leader>fg', '<cmd>Pick grep_live<CR>', { desc = '[F]ind by [G]rep' })
keymap('n', '<leader>fw', '<cmd>Pick grep<CR>', { desc = '[F]ind by [W]ord' })
keymap('n', '<leader>fW', '<cmd>Pick grep pattern="<cword>"<CR>', { desc = '[F]ind current [W]ord' })
keymap('n', '<leader>fd', '<cmd>Pick diagnostic<CR>', { desc = '[F]ind [D]iagnostics' })
keymap('n', '<leader>fD', '<cmd>Pick diagnostic scope="all"<CR>', { desc = '[F]ind [D]iagnostics All' })
keymap('n', '<leader>fr', '<cmd>Pick lsp scope="references"<CR>', { desc = '[F]ind [R]eferences' })
keymap('n', '<leader>fi', '<cmd>Pick lsp scope="implementation"<CR>', { desc = '[F]ind [I]mplementation' })
keymap('n', '<leader>f/', '<cmd>Pick history scope="/"<CR>', { desc = '[F]ind [/]' })
keymap('n', '<leader>f:', '<cmd>Pick history scope=":"<CR>', { desc = '[F]ind [:]' })
keymap('n', '<leader>/', '<cmd>Pick buf_lines<CR>', { desc = '[/] in Buffer' })
keymap('n', '<leader>fh', '<cmd>Pick git_files scope="ignored"<CR>', { desc = '[F]ind [H]idden' })
keymap('n', '<leader>fo', '<cmd>Pick oldfiles<CR>', { desc = '[F]ind recently [O]pened files' })

-- Git
keymap('n', '<leader>GD', '<cmd>Git diff<CR>', { desc = '[G]it [d]iff' })
keymap('n', '<leader>GS', '<cmd>Git status<CR>', { desc = '[G]it [S]tatus' })
keymap('n', '<leader>sc', '<cmd>lua MiniGit.show_at_cursor()<CR>', { desc = 'Git [S]how at [C]ursor' })
keymap('n', '<leader>sh', '<cmd>lua MiniGit.show_range_history()<CR>', { desc = 'Git [S]how range [H]istory' })

-- Diff
keymap('n', '<leader>go', '<cmd>lua MiniDiff.toggle_overlay()<CR>', { desc = '[G]it [O]verlay' })

-- Files
keymap('', '<C-e>', function()
  require('mini.files').open(vim.api.nvim_buf_get_name(0))
end, { silent = true })

-- MiniFiles autocmds
local ui_open = function() vim.ui.open(require('mini.files').get_fs_entry().path) end
vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    local b = args.data.buf_id
    vim.keymap.set('n', 'gX', ui_open, { buffer = b, desc = 'OS open' })
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesWindowUpdate',
  callback = function(args)
    local win_id = args.data.win_id
    local config = vim.api.nvim_win_get_config(win_id)
    local opts = vim.tbl_deep_extend('force', config, require('util.mini_helper').win_config())
    vim.api.nvim_win_set_config(win_id, opts)
  end,
})
