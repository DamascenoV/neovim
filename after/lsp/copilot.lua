return {
  cmd = { 'copilot-language-server', '--stdio' },
  root_markers = { '.git' },
  init_options = {
    editorInfo = {
      name = 'Neovim',
      version = tostring(vim.version()),
    },
    editorPluginInfo = {
      name = 'Neovim',
      version = tostring(vim.version()),
    },
  },
  settings = {
    telemetry = {
      telemetryLevel = 'all',
    },
  },
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(
      bufnr,
      'LspCopilotSignIn',
      function() require('util.copilot_helper').sign_in(bufnr, client) end,
      { desc = 'Sign in Copilot with GitHub' }
    )
    vim.api.nvim_buf_create_user_command(
      bufnr,
      'LspCopilotSignOut',
      function() require('util.copilot_helper').sign_out(bufnr, client) end,
      { desc = 'Sign out Copilot with GitHub' }
    )
  end,
}
