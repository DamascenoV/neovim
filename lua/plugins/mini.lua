return {
  'echasnovski/mini.nvim',
  version = false,
  event = "VeryLazy",
  config = function()
    local icons = require('mini.icons')
    icons.setup()
    icons.tweak_lsp_kind()

    require('mini.statusline').setup()
    local mini_notify = require('mini.notify')
    mini_notify.setup()
    vim.notify = mini_notify.make_notify()

    require('mini.surround').setup()
    require('mini.ai').setup()
    require('mini.pairs').setup()
    require('mini.git').setup()
    require('mini.diff').setup()
    require('mini.jump').setup()
    require('mini.splitjoin').setup()
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

    local mini_indentscope = require('mini.indentscope')
    mini_indentscope.setup({
      draw = {
        delay = 0,
        animation = mini_indentscope.gen_animation.none()
      },
      symbol = '│',
    })

    local mini_bufremove = require('mini.bufremove')
    mini_bufremove.setup()

    local mini_pick = require('mini.pick')
    mini_pick.setup({
      window = {
        config = {
          width = vim.api.nvim_win_get_width(0),
          height = 14,
        },
        prompt_prefix = '|> '
      },
      mappings = {
        delete_buffer = {
          char = '<C-d>',
          func = function()
            local matches = mini_pick.get_picker_matches()
            if not matches or not matches.current.bufnr then return end

            local buf_id = matches.current.bufnr
            if mini_bufremove.delete(buf_id) then
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
    require('mini.extra').setup()

    require('mini.completion').setup({
      window = {
        info = { height = 25, width = 80, border = 'rounded' },
        signature = { height = 25, width = 80, border = 'rounded' },
      },
    })

    local mini_snippets = require('mini.snippets')
    mini_snippets.setup({
      snippets = {
        mini_snippets.gen_loader.from_lang()
      },
      mappings = {
        expand = '<C-e>',
      }
    })

    require('mini.files').setup({
      mappings = {
        close = '<C-c>',
        go_in = 'L',
        go_in_plus = '<CR>',
        go_out = 'H',
        go_out_plus = '-',
      },
      windows = {
        max_number = 1,
        width_focus = vim.api.nvim_win_get_width(0),
      },
    })

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
  end,
}
