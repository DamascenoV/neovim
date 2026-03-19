local M = {}

local signature = require('util.lsplit')

M.ns_id = nil ---@type integer|nil
M.selected = -1 ---@type integer
M.items = {} ---@type table[]
M.attached = false ---@type boolean

local function is_valid_win(winid)
  return winid ~= nil and vim.api.nvim_win_is_valid(winid)
end

local function is_valid_buf(bufnr)
  return bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr)
end

local function split_is_open()
  return is_valid_buf(signature.hover_bufnr) and is_valid_win(signature.hover_winid)
end

local function set_split_lines(lines)
  if not is_valid_buf(signature.hover_bufnr) then
    return
  end

  vim.bo[signature.hover_bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(signature.hover_bufnr, 0, -1, false, lines)
  vim.bo[signature.hover_bufnr].modifiable = false
end

local function render_items()
  if not split_is_open() then
    return
  end

  local lines = {}
  for i, item in ipairs(M.items) do
    local word = item[1] or ''
    local kind = item[2] or ''
    local menu = item[3] or ''
    local entry = word
    if kind ~= '' then
      entry = entry .. '  ' .. kind
    end
    if menu ~= '' then
      entry = entry .. '  ' .. menu
    end
    if i - 1 == M.selected then
      entry = '> ' .. entry
    else
      entry = '  ' .. entry
    end
    table.insert(lines, entry)
  end

  set_split_lines(lines)

  if M.ns_id and is_valid_buf(signature.hover_bufnr) then
    vim.api.nvim_buf_clear_namespace(signature.hover_bufnr, M.ns_id, 0, -1)
    if M.selected >= 0 and M.selected < #M.items then
      vim.api.nvim_buf_add_highlight(signature.hover_bufnr, M.ns_id, 'PmenuSel', M.selected, 0, -1)
    end
  end
end

local function ui_handler(event, ...)
  if event == 'popupmenu_show' then
    local items, selected = ...
    M.items = items
    M.selected = selected
    render_items()
  elseif event == 'popupmenu_select' then
    local selected = ...
    M.selected = selected
    render_items()
  elseif event == 'popupmenu_hide' then
    M.items = {}
    M.selected = -1
    if split_is_open() then
      set_split_lines({})
    end
  end
end

function M.attach()
  if M.attached then
    return
  end
  M.attached = true
  vim.ui_attach(M.ns_id, { ext_popupmenu = true }, ui_handler)
end

function M.detach()
  if not M.attached then
    return
  end
  M.attached = false
  vim.ui_detach(M.ns_id)
  M.items = {}
  M.selected = -1
end

local function redirect_completion_window(args)
  if not split_is_open() then
    return
  end

  local data = args.data
  if not data or not data.win_id then
    return
  end

  local float_win = data.win_id
  if not is_valid_win(float_win) then
    return
  end

  local float_buf = vim.api.nvim_win_get_buf(float_win)
  local lines = vim.api.nvim_buf_get_lines(float_buf, 0, -1, false)
  if not lines or #lines == 0 then
    return
  end

  local kind = data.kind or 'info'
  local header = kind == 'signature' and '### Signature' or '### Info'
  table.insert(lines, 1, header)
  table.insert(lines, 2, '')

  set_split_lines(lines)

  vim.schedule(function()
    if is_valid_win(float_win) then
      vim.api.nvim_win_close(float_win, true)
    end
  end)
end

function M.setup()
  M.ns_id = vim.api.nvim_create_namespace('CompletionSplit')

  vim.api.nvim_create_autocmd('User', {
    pattern = { 'MiniCompletionWindowOpen', 'MiniCompletionWindowUpdate' },
    callback = redirect_completion_window,
  })
end

return M
