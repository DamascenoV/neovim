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

-- Cursorline control
local cursorline_group = vim.api.nvim_create_augroup('CursorLineControl', { clear = true })
local set_cursor_line = function(event, value, pattern)
  vim.api.nvim_create_autocmd(event, {
    group = cursorline_group,
    pattern = pattern,
    callback = function() vim.opt_local.cursorline = value end,
  })
end
set_cursor_line('WinLeave', false)
set_cursor_line('WinEnter', true)

-- Terminal settings
local terminal_group = vim.api.nvim_create_augroup('TerminalSettings', { clear = true })
vim.api.nvim_create_autocmd('TermOpen', {
  group = terminal_group,
  callback = function()
    vim.cmd('startinsert')
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})
vim.api.nvim_create_autocmd('TermEnter', {
  group = terminal_group,
  callback = function()
    vim.opt_local.signcolumn = 'no'
  end,
})

-- Ripgrep integration
if vim.fn.executable "rg" == 1 then
  function _G.RgFindFiles(cmdarg)
    local fnames = vim.fn.systemlist 'rg --files --hidden --color=never --glob="!.git" --glob="!node_modules/"'
    if #cmdarg == 0 then
      return fnames
    else
      return vim.fn.matchfuzzy(fnames, cmdarg)
    end
  end

  vim.o.findfunc = "v:lua.RgFindFiles"
  vim.o.grepprg = [[rg --vimgrep]]
end
