-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({
      higroup = 'IncSearch',
      timeout = 40,
    })
  end,
  group = highlight_group,
  pattern = '*',
})

-- Resize splits if window got resized
vim.api.nvim_create_autocmd({ 'VimResized' }, {
  callback = function() vim.cmd('tabdo wincmd =') end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client then client.server_capabilities.semanticTokensProvider = nil end

    if vim.fn.has('nvim-0.12') == 0 then return end
    local bufnr = args.buf
    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr) then
      vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

      vim.keymap.set(
        'i',
        '<C-f>',
        vim.lsp.inline_completion.get,
        { desc = 'LSP: accept inline completion', buffer = bufnr }
      )
      vim.keymap.set(
        'i',
        '<C-g>',
        vim.lsp.inline_completion.select,
        { desc = 'LSP: switch inline completion', buffer = bufnr }
      )
    end
  end,
})

local group
vim.api.nvim_create_augroup('CursorLineControl', { clear = true })
local set_cursor_line = function(event, value, pattern)
  vim.api.nvim_create_autocmd(event, {
    group = group,
    pattern = pattern,
    callback = function() vim.opt_local.cursorline = value end,
  })
end
set_cursor_line('WinLeave', false)
set_cursor_line('WinEnter', true)

vim.api.nvim_command('autocmd TermOpen * startinsert')                        -- starts in insert mode
vim.api.nvim_command('autocmd TermOpen * setlocal nonumber norelativenumber') -- no numbers
vim.api.nvim_command('autocmd TermEnter * setlocal signcolumn=no')            -- no sign column

if vim.fn.executable "rg" == 1 then
  function _G.RgFindFiles(cmdarg, _cmdcomplete)
    local fnames = vim.fn.systemlist 'rg --files --hidden --color=never --glob="!.git" --glob="!node_modules/"'
    if #cmdarg == 0 then
      return fnames
    else
      return vim.fn.matchfuzzy(fnames, cmdarg)
    end
  end

  vim.o.findfunc = "v:lua.RgFindFiles"
  vim.o.grepprg = [[rg --vimgrep]]

  vim.api.nvim_create_user_command('Rg', function(opts)
    local args = opts.args
    if args == '' then
      args = vim.fn.input('Rg: ')
    end
    if args ~= '' then
      vim.cmd('silent grep! ' .. args)
      vim.cmd('copen')
    end
  end, { nargs = '*', desc = 'Search for a pattern using rg' })
end
