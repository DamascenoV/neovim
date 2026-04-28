local api = vim.api

local M = {}

local preview_buf, preview_win
local preview_lines
local preview_syntax
local preview_height
local ts_active = false

local function same_lines(a, b)
  if a == b then return true end
  if a == nil or b == nil then return false end
  if #a ~= #b then return false end
  for i = 1, #a do
    if a[i] ~= b[i] then return false end
  end
  return true
end

local function reset_state()
  preview_buf = nil
  preview_win = nil
  preview_lines = nil
  preview_syntax = nil
  preview_height = nil
  ts_active = false
end

local function ensure_window(height)
  if
    preview_buf and api.nvim_buf_is_valid(preview_buf)
    and preview_win and api.nvim_win_is_valid(preview_win)
  then
    if height ~= preview_height then
      api.nvim_win_set_height(preview_win, height)
      preview_height = height
    end
    return
  end

  if preview_buf and api.nvim_buf_is_valid(preview_buf) then
    pcall(api.nvim_buf_delete, preview_buf, { force = true })
  end

  preview_buf = api.nvim_create_buf(false, true)
  api.nvim_set_option_value('bufhidden', 'wipe', { buf = preview_buf })
  api.nvim_set_option_value('modifiable', false, { buf = preview_buf })
  api.nvim_set_option_value('swapfile', false, { buf = preview_buf })

  vim.cmd('botright ' .. height .. 'split')
  preview_win = api.nvim_get_current_win()
  api.nvim_win_set_buf(preview_win, preview_buf)

  api.nvim_set_option_value('winfixheight', true, { win = preview_win })
  api.nvim_set_option_value('number', false, { win = preview_win })
  api.nvim_set_option_value('relativenumber', false, { win = preview_win })
  api.nvim_set_option_value('signcolumn', 'no', { win = preview_win })
  api.nvim_set_option_value('colorcolumn', '', { win = preview_win })

  preview_height = height

  api.nvim_create_autocmd('BufWipeout', {
    buffer = preview_buf,
    callback = reset_state,
  })
end

local function update_buffer(contents)
  if same_lines(preview_lines, contents) then return end
  api.nvim_set_option_value('modifiable', true, { buf = preview_buf })
  api.nvim_buf_set_lines(preview_buf, 0, -1, false, contents)
  api.nvim_set_option_value('modifiable', false, { buf = preview_buf })
  preview_lines = contents
end

local function update_syntax(syntax)
  if syntax == preview_syntax then return end

  if syntax and syntax ~= '' then
    api.nvim_set_option_value('filetype', syntax, { buf = preview_buf })
  end
  preview_syntax = syntax

  if syntax == 'markdown' then
    if not ts_active then
      pcall(vim.treesitter.start, preview_buf)
      ts_active = true
    end
    api.nvim_set_option_value('conceallevel', 2, { win = preview_win })
  else
    if ts_active then
      pcall(vim.treesitter.stop, preview_buf)
      ts_active = false
    end
    api.nvim_set_option_value('conceallevel', 0, { win = preview_win })
  end
end

---@diagnostic disable-next-line: duplicate-set-field
local function open_floating_preview(contents, syntax, opts)
  opts = opts or {}
  local prev_win = api.nvim_get_current_win()
  local height = opts.height or math.max(math.floor(vim.o.lines * 0.25), 3) - 1

  ensure_window(height)

  if not (preview_buf and api.nvim_buf_is_valid(preview_buf)) then
    return nil, nil
  end

  update_buffer(contents)
  update_syntax(syntax)

  if opts.focus then
    api.nvim_set_current_win(preview_win)
  elseif prev_win and api.nvim_win_is_valid(prev_win) then
    api.nvim_set_current_win(prev_win)
  end

  return preview_buf, preview_win
end

function M.setup()
  vim.lsp.util.open_floating_preview = open_floating_preview
end

return M
