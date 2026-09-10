local now, later, now_if_args = Config.now, Config.later, Config.now_if_args
local helper = require('util.mini_helper')

now(function() require('mini.statusline').setup() end)

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
      use_as_default_explorer = true
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

now_if_args(function()
  local completion = require('mini.completion')
  local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
  local process_items = function(items, base)
    return completion.default_process_items(items, base, process_items_opts)
  end
  completion.setup({
    lsp_completion = {
      source_func = 'omnifunc',
      auto_setup = false,
      process_items = process_items,
    },
  })

  local on_attach = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
  end
  Config.new_autocmd('LspAttach', nil, on_attach, "Set 'omnifunc'")

  vim.lsp.config('*', { capabilities = completion.get_lsp_capabilities() })
end)

now_if_args(function()
  local misc = require('mini.misc')
  misc.setup()
  misc.setup_auto_root()
end)

-- MiniFiles autocmds
local ui_open = function() vim.ui.open(require('mini.files').get_fs_entry().path) end

Config.new_autocmd('User', 'MiniFilesBufferCreate',
  function(args)
    local b = args.data.buf_id
    vim.keymap.set('n', 'gX', ui_open, { buffer = b, desc = 'OS open' })
  end
)

Config.new_autocmd('User', 'MiniFilesWindowUpdate', function(args)
    local win_id = args.data.win_id
    local config = vim.api.nvim_win_get_config(win_id)
    local opts = vim.tbl_deep_extend('force', config, helper.win_config())
    vim.api.nvim_win_set_config(win_id, opts)
  end
)
