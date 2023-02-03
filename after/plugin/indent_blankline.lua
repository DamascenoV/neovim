local status, indent_blankline = pcall(require, 'indent_blankline')
if not status then return end

indent_blankline.setup {
  char = '┊',
  show_trailing_blankline_indent = false,
  show_current_context = true,
  show_current_context_start = true,
}

