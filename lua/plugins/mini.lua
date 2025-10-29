local later, now = MiniDeps.later, MiniDeps.now

now(function() require('mini.notify').setup() end)
now(function() require('mini.icons').setup() end)
now(function() require('mini.statusline').setup() end)

later(function() require('mini.surround').setup() end)
later(function() require('mini.ai').setup() end)
later(function() require('mini.diff').setup() end)
later(function() require('mini.jump').setup() end)
later(function() require('mini.splitjoin').setup() end)
later(function() require('mini.bufremove').setup() end)

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
      config = {
        width = vim.o.columns,
        height = math.floor(vim.o.lines / 3),
      },
      prompt_prefix = '|> '
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
  require('mini.completion').setup({
    window = {
      info = { height = 25, width = 80 },
      signature = { height = 25, width = 80 },
    },
  })
end)

later(function()
  local mini_snippets = require('mini.snippets')
  mini_snippets.setup({
    snippets = {
      mini_snippets.gen_loader.from_lang()
    },
    mappings = {
      expand = '<C-e>',
    }
  })
  mini_snippets.start_lsp_server()
end)

later(function()
  local ls_prefix = require('helpers.permissions_ls').ls_prefix
  require('mini.files').setup({
    content = {
      prefix = ls_prefix
    },
    mappings = {
      close = '<C-c>',
      go_in = 'L',
      go_in_plus = '<CR>',
      go_out = 'H',
      go_out_plus = '-',
    },
    options = {
      use_as_default_explorer = false
    },
    windows = {
      max_number = 1,
      width_focus = vim.api.nvim_win_get_width(0),
    },
  })
end)
