vim.lsp.enable({
  "cssls",
  "copilot",
  "emmet_language_server",
  'intelephense',
  'lua_ls',
  "vtsls",
  "vue_ls",
  "laravel_ls",
  "gopls",
  "golangci_lint_ls",
  "zls",
  "ols",
  -- 'elixirls',
  "expert"
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
    map('n', 'K', require('util.lsplit').split)
    map('n', 'gi', vim.lsp.buf.implementation)
    map('n', '<leader>rn', vim.lsp.buf.rename)
    map('n', '<space>K', vim.lsp.buf.signature_help, { desc = 'Signature' })
    map('n', '<space>wa', vim.lsp.buf.add_workspace_folder)
    map('n', '<space>wr', vim.lsp.buf.remove_workspace_folder)
    map('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end)
    map('n', '<space>td', vim.lsp.buf.type_definition, { desc = '[T]ype [D]efinition' })
    map({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, { desc = '[C]ode [A]ction' })
    map('n', 'gr', vim.lsp.buf.references)
    map('n', '<space>fm', function() vim.lsp.buf.format({ async = true }) end, { desc = '[F]ormat' })

    if vim.fn.has('nvim-0.12') == 0 then return end
    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr) then
      vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

      map('i', '<C-f>', vim.lsp.inline_completion.get, { desc = 'LSP: accept inline completion' })
      map('i', '<C-g>', vim.lsp.inline_completion.select, { desc = 'LSP: switch inline completion' })
    end
  end,
})
