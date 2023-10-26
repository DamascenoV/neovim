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
      }
    },
  },
  pickers = {
    find_files = {
      theme = "dropdown",
      previewer = false,
    },
    colorscheme = {
      enable_preview = true
    }
  }
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'project')
