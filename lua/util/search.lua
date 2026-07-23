local M = {}

local function rg_command(query)
  local args = vim.split(vim.o.grepprg, '%s+', { trimempty = true })
  args = vim.tbl_map(function(arg)
    return (arg:gsub('^["\']', ''):gsub('["\']$', ''))
  end, args)
  vim.list_extend(args, { '--', query, '.' })
  return args
end

function M.grep(query)
  query = vim.trim(query or '')
  if query == '' then return end

  if vim.fn.executable('rg') ~= 1 then
    vim.notify('ripgrep (rg) is not installed', vim.log.levels.ERROR)
    return
  end

  local command = rg_command(query)
  local title = 'Grep: ' .. query

  vim.system(command, { text = true }, function(result)
    vim.schedule(function()
      if result.code > 1 then
        local err = vim.trim(result.stderr or '')
        vim.notify(err, vim.log.levels.ERROR, { title = 'Grep failed' })
        return
      end

      local output = result.stdout or ''
      local lines = vim.split(output, '\n', { trimempty = true })

      vim.fn.setqflist({}, ' ', {
        title = title,
        lines = lines,
        efm = vim.o.grepformat,
      })

      if #lines == 0 then
        vim.notify('No matches for: ' .. query, vim.log.levels.INFO)
        return
      end

      vim.cmd('botright copen')
    end)
  end)
end

function M.setup()
  vim.api.nvim_create_user_command('Grep', function(opts) M.grep(opts.args) end, {
    nargs = '+',
    desc = 'Search the project with ripgrep (spaces are supported)',
  })
end

return M
