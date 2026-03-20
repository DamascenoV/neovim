local M = {}

local signature = require('util.lsplit')

M.ns_id = vim.api.nvim_create_namespace('CompletionSplit') ---@type integer
M.selected = -1 ---@type integer
M.items = {} ---@type table[]
M.attached = false ---@type boolean
M.complete_augroup = nil ---@type integer|nil

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

local function show_item_docs()
  if not split_is_open() then
    return
  end

  local event = vim.v.event
  if not event then
    return
  end

  local item = event.completed_item
  if not item or vim.tbl_isempty(item) then
    return
  end

  local info = item.info or ''
  if info == '' then
    return
  end

  local lines = vim.split(info, '\n', { trimempty = true })
  if #lines == 0 then
    return
  end

  table.insert(lines, 1, '### Info')
  table.insert(lines, 2, '')
  set_split_lines(lines)
end

function M.attach()
  if M.attached then
    return
  end
  M.attached = true
  vim.ui_attach(M.ns_id, { ext_popupmenu = true }, ui_handler)

  M.complete_augroup = vim.api.nvim_create_augroup('CompletionSplitAu', { clear = true })

  vim.api.nvim_create_autocmd('CompleteChanged', {
    group = M.complete_augroup,
    callback = show_item_docs,
  })

  vim.api.nvim_create_autocmd('CompleteDonePre', {
    group = M.complete_augroup,
    callback = function()
      if split_is_open() then
        set_split_lines({})
      end
    end,
  })
end

function M.detach()
  if not M.attached then
    return
  end
  M.attached = false
  vim.ui_detach(M.ns_id)
  M.items = {}
  M.selected = -1

  if M.complete_augroup then
    vim.api.nvim_del_augroup_by_id(M.complete_augroup)
    M.complete_augroup = nil
  end
end

return M
