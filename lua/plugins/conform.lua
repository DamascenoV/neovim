return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  opts = {
    formatters_by_ft = {
      javascript = { 'prettier' },
      vue = { 'prettier' },
      json = { 'prettier' },
      lua = { 'stylua' },
    },
    format_on_save = { timeout_ms = 500 },
  },
}
