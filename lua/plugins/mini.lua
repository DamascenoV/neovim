return {
  "echasnovski/mini.nvim",
  version = false,
  config = function()
    local icons = require("mini.icons")
    icons.setup()
    icons.tweak_lsp_kind()

    require("mini.statusline").setup({
      set_vim_settings = false
    })
    local notify = require("mini.notify")
    notify.setup()
    vim.notify = notify.make_notify()

    require("mini.surround").setup()
    require("mini.ai").setup()
    require("mini.git").setup()
    require("mini.diff").setup()
    require("mini.pairs").setup()
    require('mini.splitjoin').setup()
    require("mini.move").setup({
      mappings = {
        left = '<C-left>',
        right = '<C-right>',
        down = '<C-down>',
        up = '<C-up>',
        line_left = '<C-left>',
        line_right = '<C-right>',
        line_down = '<C-down>',
        line_up = '<C-up>',
      }
    })

    local minipick = require('mini.pick')
    minipick.setup({
      options = {
        content_from_bottom = true,
      },
      window = {
        config = {
          width = vim.api.nvim_win_get_width(0),
          height = 14
        }
      },
      mappings = {
        delete_buffer = {
          char = '<C-d>',
          func = function()
            local matches = minipick.get_picker_matches()
            if not matches or not matches.current.bufnr then return end

            local buf_id = matches.current.bufnr
            if require('mini.bufremove').delete(buf_id) then
              local items = vim.tbl_filter(function(item)
                return item.bufnr ~= buf_id
              end, minipick.get_picker_items() or {})
              minipick.set_picker_items(items)
            end
          end
        }
      }
    })
    require('mini.extra').setup()


    require("mini.completion").setup({
      window = {
        info = { height = 25, width = 80, border = 'rounded' },
        signature = { height = 25, width = 80, border = 'rounded' },
      },
    })

    require("mini.snippets").setup()

    require("mini.files").setup({
      mappings = {
        close = '<C-c>',
        go_in = 'L',
        go_in_plus = '<CR>',
        go_out = 'H',
        go_out_plus = '-'
      },
      windows = {
        max_number = 1,
        width_focus = 100
      }
    })
  end
}
