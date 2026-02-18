local M = {}

M.snippets = {}

function M.load_snippets_for_ft()
  local ft = vim.bo.filetype
  M.snippets[ft] = {}

  local paths = {
    vim.fn.stdpath('config') .. '/after/snippets/' .. ft .. '.json',
    vim.fn.stdpath('config') .. '/after/snippets/global.json',
  }

  for _, path in ipairs(paths) do
    if vim.fn.filereadable(path) == 1 then
      local ok, content = pcall(vim.fn.readfile, path)
      if ok then
        local json = table.concat(content, '\n')
        local ok2, snippets = pcall(vim.json.decode, json)
        if ok2 then
          for name, snippet in pairs(snippets) do
            M.snippets[ft][snippet.prefix] = {
              body = type(snippet.body) == 'table' and table.concat(snippet.body, '\n') or snippet.body,
              desc = snippet.description or name,
            }
          end
        end
      end
    end
  end
end

function M.expand()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before_cursor = line:sub(1, col)
  local word = before_cursor:match('(%w+)$')
  if not word then return end

  local ft = vim.bo.filetype
  local snippets = M.snippets[ft] or {}
  local snippet = snippets[word]

  if snippet then
    local new_line = before_cursor:sub(1, - #word - 1) .. line:sub(col + 1)
    vim.api.nvim_set_current_line(new_line)
    vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], col - #word })

    vim.snippet.expand(snippet.body)
  end
end

function M.list()
  local ft = vim.bo.filetype
  local snippets = M.snippets[ft] or {}
  local items = {}

  for prefix, snippet in pairs(snippets) do
    table.insert(items, string.format('%s - %s', prefix, snippet.desc))
  end

  if #items == 0 then
    print('No snippets available for ' .. ft)
    return
  end

  vim.ui.select(items, {
    prompt = 'Select snippet:',
  }, function(choice)
    if choice then
      local prefix = choice:match('^(%w+)')
      -- Insert the prefix
      vim.api.nvim_put({ prefix }, 'c', true, true)
      M.expand()
    end
  end)
end

vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    M.load_snippets_for_ft()
  end,
})

vim.keymap.set('i', '<C-j>', M.expand, { desc = 'Expand snippet' })
vim.keymap.set('i', '<C-s>', M.list, { desc = 'List snippets' })

vim.api.nvim_create_user_command('Snippets', M.list, {})

M.load_snippets_for_ft()

return M
