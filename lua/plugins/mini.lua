local later, now = MiniDeps.later, MiniDeps.now

now(function()
  require('mini.notify').setup()
  vim.notify = require('mini.notify').make_notify()
end)
now(function() require('mini.icons').setup() end)
now(function() require('mini.statusline').setup() end)

now(function()
  local mini_starter = require('mini.starter')
  mini_starter.setup({
    evaluate_single = true,
    items = {
      mini_starter.sections.pick(),
      mini_starter.sections.builtin_actions(),
    },
    footer = os.date("%B %d, %I:%M %p")
  })
end)

later(function() require('mini.surround').setup() end)
later(function() require('mini.ai').setup() end)
later(function() require('mini.pairs').setup() end)
later(function() require('mini.diff').setup() end)
later(function() require('mini.jump').setup() end)
later(function() require('mini.splitjoin').setup() end)
later(function() require('mini.bufremove').setup() end)

later(function()
  require('mini.operators').setup({
    replace = {
      prefix = 'gR',
    }
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

later(function()
  require('mini.move').setup({
    mappings = {
      left = '<C-left>',
      right = '<C-right>',
      down = '<C-down>',
      up = '<C-up>',
      line_left = '<C-left>',
      line_right = '<C-right>',
      line_down = '<C-down>',
      line_up = '<C-up>',
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

later(function()
  require('mini.visits').setup()
end)

later(function()
  local mini_clue = require('mini.clue')
  mini_clue.setup({
    triggers = {
      { mode = 'n', keys = '<Leader>' },
      { mode = 'x', keys = '<Leader>' },
      { mode = 'i', keys = '<C-x>' },
      { mode = 'n', keys = 'g' },
      { mode = 'x', keys = 'g' },
      { mode = 'n', keys = "'" },
      { mode = 'n', keys = '`' },
      { mode = 'x', keys = "'" },
      { mode = 'x', keys = '`' },
      { mode = 'n', keys = '"' },
      { mode = 'x', keys = '"' },
      { mode = 'i', keys = '<C-r>' },
      { mode = 'c', keys = '<C-r>' },
      { mode = 'n', keys = '<C-w>' },
      { mode = 'n', keys = 'z' },
      { mode = 'x', keys = 'z' },
    },
    clues = {
      mini_clue.gen_clues.builtin_completion(),
      mini_clue.gen_clues.g(),
      mini_clue.gen_clues.marks(),
      mini_clue.gen_clues.registers(),
      mini_clue.gen_clues.windows(),
      mini_clue.gen_clues.z(),
    },
  })
end)
