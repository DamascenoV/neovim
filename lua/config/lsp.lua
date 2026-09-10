require('util.lsp_preview').setup()

vim.lsp.enable({
  'cssls',
  'emmet_ls',
  'intelephense',
  'emmylua_ls',
  'tsgols',
  'vize',
  'laravel_ls',
  'gopls',
  'golangci_lint_ls',
  'zls',
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
  end,
})
