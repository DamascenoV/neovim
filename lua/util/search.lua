local M = {}
local rg = require('util.rg')
local cancel
local generation = 0

function M.grep(query)
  if not query or vim.trim(query) == '' then return end
  generation = generation + 1
  local request = generation
  if cancel then cancel() end
  local cwd = require('util.repo').project()
  cancel = rg.start('grep', { cwd = cwd, query = query }, function(items, result)
    if request ~= generation then return end
    cancel = nil
    if result.code > 1 or result.code < 0 then
      vim.notify(result.error, vim.log.levels.ERROR, { title = 'Grep failed' })
      return
    end
    local qf = {}
    for _, item in ipairs(items) do
      qf[#qf + 1] = { filename = item.path, lnum = item.lnum, col = item.col, text = item.text }
    end
    local title = 'Grep: ' .. query .. (result.truncated and ' (limit reached)' or '')
    vim.fn.setqflist({}, ' ', { title = title, items = qf })
    if #qf == 0 then
      vim.notify('No matches for: ' .. query, vim.log.levels.INFO)
      return
    end
    vim.cmd('botright copen')
  end)
end

---Shared options for :Grep and Pick grep/files/hidden.
function M.setup(opts)
  rg.setup(opts)
  vim.opt.grepprg = 'rg --vimgrep --smart-case --hidden --glob "!.git" --glob "!.jj"'
  vim.opt.grepformat = '%f:%l:%c:%m'

  vim.api.nvim_create_user_command('Grep', function(opts) M.grep(opts.args) end, {
    nargs = '+',
    desc = 'Search the project with ripgrep (spaces are supported)',
  })
end

return M
