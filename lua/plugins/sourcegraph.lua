return {
  'sourcegraph/sg.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
  -- enabled = false,
  opts = {
    accept_tos = true,
    chat = {
      default_model = 'opeani/gpt-40'
    }
  }
}
