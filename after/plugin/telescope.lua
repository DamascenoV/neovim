local status, telescope = pcall(require, 'telescope')
if not status then return end

local actions = require('telescope.actions')

telescope.setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = actions.delete_buffer,
      },
      n = {
        ['<C-d>'] = actions.delete_buffer,
        ['<C-c>'] = actions.close,
        ['<C-k>'] = actions.preview_scrolling_up,
        ['<C-j>'] = actions.preview_scrolling_down
      }
    },
  },
  pickers = {
    colorscheme = {
      enable_preview = true
    }
  }
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
