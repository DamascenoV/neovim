-- LINT
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  callback = function()
    require("lint").try_lint()
  end
})

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

local group
vim.api.nvim_create_augroup("CursorLineControl", { clear = true })
local set_cursor_line = function(event, value, pattern)
  vim.api.nvim_create_autocmd(event, {
    group = group,
    pattern = pattern,
    callback = function()
      vim.opt_local.cursorline = value
    end,
  })
end

vim.api.nvim_command("autocmd TermOpen * startinsert")             -- starts in insert mode
vim.api.nvim_command("autocmd TermOpen * setlocal nonumber norelativenumber")       -- no numbers
vim.api.nvim_command("autocmd TermEnter * setlocal signcolumn=no") -- no sign column

set_cursor_line('WinLeave', false)
set_cursor_line("WinEnter", true)
set_cursor_line('FileType', false, 'TelescopePrompt')
