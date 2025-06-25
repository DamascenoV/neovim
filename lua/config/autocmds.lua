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
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then client.server_capabilities.semanticTokensProvider = nil end
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

vim.api.nvim_command('autocmd TermOpen * startinsert')                        -- starts in insert mode
vim.api.nvim_command('autocmd TermOpen * setlocal nonumber norelativenumber') -- no numbers
vim.api.nvim_command('autocmd TermEnter * setlocal signcolumn=no')            -- no sign column

set_cursor_line('WinLeave', false)
set_cursor_line('WinEnter', true)
