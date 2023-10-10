local status, indent_blankline = pcall(require, 'ibl')
if not status then return end

indent_blankline.setup {
  indent = {
    char = '┊',
    smart_indent_cap = true,
  },
  scope = {
    enabled = true
  }
}
