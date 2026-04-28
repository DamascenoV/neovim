require('util.lsp_preview').setup()

vim.lsp.enable({
  'cssls',
  'copilot',
  'emmet_ls',
  'intelephense',
  'lua_ls',
  'vtsls',
  'vue_ls',
  'laravel_ls',
  'gopls',
  'golangci_lint_ls',
  'zls',
  'ols',
  -- 'elixirls',
  'expert',
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client then client.server_capabilities.semanticTokensProvider = nil end

    local bufnr = args.buf
    local map = function(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    map('n', 'gD', vim.lsp.buf.declaration)
    map('n', 'gd', vim.lsp.buf.definition)
    map('n', 'K', vim.lsp.buf.hover)
    map('n', '<leader>rn', vim.lsp.buf.rename)
    map('n', '<leader>fm', function() vim.lsp.buf.format({ async = true }) end, { desc = '[F]ormat' })

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr) then
      vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

      map('i', '<C-f>', vim.lsp.inline_completion.get, { desc = 'LSP: accept inline completion' })
      map('i', '<C-g>', vim.lsp.inline_completion.select, { desc = 'LSP: switch inline completion' })
    end
  end,
})
