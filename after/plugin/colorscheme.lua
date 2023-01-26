local status, gruvbox = pcall(require, 'gruvbox')
if not status then return end

gruvbox.setup({
  palette_overrides = {
    bright_yellow = '#f8fe7a',
    bright_green = '#698b69',
    bright_blue = '#f2e5bc',
    bright_orange = '#8e6fbd',
    bright_red = '#cc6666',
    bright_purple = '#fb4934',
    neutral_yellow = '#f8fe7a',
  },
  overrides = {
  },
  transparent_mode = true,
})
vim.cmd("colorscheme gruvbox")
