do
  local preview_buf, preview_win, preview_syntax

  ---@diagnostic disable-next-line: duplicate-set-field
  vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
    opts = opts or {}
    local prev_win = vim.api.nvim_get_current_win()

    if preview_buf and vim.api.nvim_buf_is_valid(preview_buf)
        and preview_win and vim.api.nvim_win_is_valid(preview_win) then
      vim.bo[preview_buf].modifiable = true
      vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, contents)
      if syntax and syntax ~= '' then
        vim.bo[preview_buf].filetype = syntax
      end
      if syntax == 'markdown' and preview_syntax ~= 'markdown' then
        vim.treesitter.start(preview_buf)
      end
      vim.wo[preview_win].conceallevel = syntax == 'markdown' and 2 or 0
      preview_syntax = syntax
      vim.bo[preview_buf].modifiable = false
      if opts.focus then
        vim.api.nvim_set_current_win(preview_win)
      end
      return preview_buf, preview_win
    end

    if preview_buf and vim.api.nvim_buf_is_valid(preview_buf) then
      vim.api.nvim_buf_delete(preview_buf, { force = true })
    end

    preview_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, contents)
    if syntax and syntax ~= '' then
      vim.bo[preview_buf].filetype = syntax
    end
    preview_syntax = syntax
    vim.bo[preview_buf].bufhidden = 'wipe'
    vim.bo[preview_buf].modifiable = false
    local height = opts.height or math.max(math.floor(vim.o.lines * 0.25), 3) - 1
    vim.cmd('botright ' .. height .. 'split')
    preview_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(preview_win, preview_buf)
    vim.wo[preview_win].winfixheight = true
    if syntax == 'markdown' then
      vim.treesitter.start(preview_buf)
      vim.wo[preview_win].conceallevel = 2
    end
    if not opts.focus then
      vim.api.nvim_set_current_win(prev_win)
    end

    vim.api.nvim_create_autocmd('BufWipeout', {
      buffer = preview_buf,
      callback = function()
        preview_buf = nil
        preview_win = nil
        preview_syntax = nil
      end,
    })

    return preview_buf, preview_win
  end
end

vim.lsp.enable({
  "cssls",
  "copilot",
  "emmet_ls",
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
    map('n', 'K', vim.lsp.buf.hover)
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

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr) then
      vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

      map('i', '<C-f>', vim.lsp.inline_completion.get, { desc = 'LSP: accept inline completion' })
      map('i', '<C-g>', vim.lsp.inline_completion.select, { desc = 'LSP: switch inline completion' })
    end
  end,
})
