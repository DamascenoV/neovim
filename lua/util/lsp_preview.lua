local api = vim.api

local M = {}

local active_preview_bufnr ---@type integer?
local active_preview_winnr ---@type integer?

local function buf_get_var(bufnr, name)
  local ok, value = pcall(api.nvim_buf_get_var, bufnr, name)
  if ok then return value end
end

local function buf_del_var(bufnr, name)
  if bufnr and api.nvim_buf_is_valid(bufnr) then pcall(api.nvim_buf_del_var, bufnr, name) end
end

local function win_get_var(winnr, name)
  local ok, value = pcall(api.nvim_win_get_var, winnr, name)
  if ok then return value end
end

local function set_buf_option(bufnr, name, value) pcall(api.nvim_set_option_value, name, value, { buf = bufnr }) end
local function set_win_option(winnr, name, value) pcall(api.nvim_set_option_value, name, value, { win = winnr }) end
local function is_valid_win(winnr) return winnr and api.nvim_win_is_valid(winnr) end

local function clear_preview_var(bufnr, winnr)
  if not (bufnr and api.nvim_buf_is_valid(bufnr)) then return end
  if buf_get_var(bufnr, 'lsp_floating_preview') == winnr then buf_del_var(bufnr, 'lsp_floating_preview') end
end

local function clear_hover_range(bufnr)
  if not (bufnr and api.nvim_buf_is_valid(bufnr)) then return end

  local hover_ns = api.nvim_create_namespace('nvim.lsp.hover_range')
  api.nvim_buf_clear_namespace(bufnr, hover_ns, 0, -1)
end

local function find_preview_window()
  local winnr = active_preview_winnr
  if winnr and api.nvim_win_is_valid(winnr) and vim.list_contains(api.nvim_tabpage_list_wins(0), winnr) then
    return winnr, api.nvim_win_get_buf(winnr)
  end

  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    if win_get_var(win, 'util_lsp_preview') then return win, api.nvim_win_get_buf(win) end
  end
end

local function make_preview_size(contents, opts)
  local ok, popup_width, popup_height = pcall(vim.lsp.util._make_floating_popup_size, contents, opts)
  if ok and popup_width and popup_height then return popup_width, popup_height end

  local fallback_width = 1
  for _, line in ipairs(contents) do
    fallback_width = math.max(fallback_width, vim.fn.strdisplaywidth(line))
  end

  if opts.wrap_at then fallback_width = math.min(fallback_width, opts.wrap_at) end
  if opts.width then fallback_width = opts.width end

  local fallback_height = opts.height or #contents
  if opts.max_height then fallback_height = math.min(fallback_height, opts.max_height) end

  return math.max(fallback_width, 1), math.max(fallback_height, 1)
end

local function normalize_contents(contents, syntax, opts)
  local do_stylize = syntax == 'markdown' and vim.g.syntax_on ~= nil

  if do_stylize then
    local width = make_preview_size(contents, opts)
    local ok, normalized = pcall(vim.lsp.util._normalize_markdown, contents, { width = width })
    if ok then return normalized, true end
  end

  return vim.split(table.concat(contents, '\n'), '\n', { trimempty = true }), false
end

local function preview_width() return math.max(vim.o.columns, 1) end
local function preview_height() return math.max(math.floor(vim.o.lines * 0.25), 1) end

local function create_preview_buf()
  local bufnr = api.nvim_create_buf(false, true)
  set_buf_option(bufnr, 'bufhidden', 'wipe')
  set_buf_option(bufnr, 'buftype', 'nofile')
  set_buf_option(bufnr, 'modifiable', false)
  set_buf_option(bufnr, 'swapfile', false)
  return bufnr
end

local function set_preview_lines(bufnr, contents)
  set_buf_option(bufnr, 'modifiable', true)
  api.nvim_buf_set_lines(bufnr, 0, -1, false, contents)
  set_buf_option(bufnr, 'modifiable', false)
end

local function apply_syntax(bufnr, winnr, syntax, do_stylize)
  if do_stylize then
    set_buf_option(bufnr, 'syntax', '')
    set_buf_option(bufnr, 'filetype', 'markdown')
    set_win_option(winnr, 'conceallevel', 2)
    set_win_option(winnr, 'concealcursor', '')
    pcall(vim.treesitter.start, bufnr)
    return
  end

  pcall(vim.treesitter.stop, bufnr)
  set_buf_option(bufnr, 'filetype', '')
  set_buf_option(bufnr, 'syntax', syntax or '')
  set_win_option(winnr, 'conceallevel', 0)
end

local function escape_statusline(value) return value:gsub('%%', '%%%%') end

local function apply_window_options(winnr, opts)
  set_win_option(winnr, 'foldenable', false)
  set_win_option(winnr, 'wrap', opts.wrap)
  set_win_option(winnr, 'linebreak', true)
  set_win_option(winnr, 'breakindent', true)
  set_win_option(winnr, 'smoothscroll', true)
  set_win_option(winnr, 'winfixheight', true)
  set_win_option(winnr, 'winfixbuf', true)
  set_win_option(winnr, 'number', false)
  set_win_option(winnr, 'relativenumber', false)
  set_win_option(winnr, 'signcolumn', 'no')
  set_win_option(winnr, 'colorcolumn', '')
  set_win_option(winnr, 'winbar', opts.title and (' ' .. escape_statusline(tostring(opts.title)) .. ' ') or '')
end

local function win_set_height(winnr, height)
  if api.nvim_win_resize then
    -- Neovim 0.13+: nvim_win_resize with anchor keeps the bottom edge fixed
    pcall(api.nvim_win_resize, winnr, -1, height, { anchor = 'bottom' })
  else
    pcall(api.nvim_win_set_height, winnr, height)
  end
end

local function resize_for_conceal(winnr, opts, do_stylize)
  if not (do_stylize and not opts.height and api.nvim_win_text_height) then return end

  local win_height = api.nvim_win_get_height(winnr)
  local ok, text_height = pcall(api.nvim_win_text_height, winnr, { max_height = win_height })
  if ok and text_height.all > 0 and text_height.all < win_height then win_set_height(winnr, text_height.all) end
end

local function setup_close_autocmds(winnr, preview_bufnr, source_bufnr)
  local group_name = ('util.lsp_preview.%d'):format(winnr)
  local group = api.nvim_create_augroup(group_name, { clear = true })

  api.nvim_create_autocmd('WinClosed', {
    group = group,
    pattern = tostring(winnr),
    once = true,
    callback = function()
      clear_preview_var(source_bufnr, winnr)
      if active_preview_winnr == winnr then
        active_preview_winnr = nil
        active_preview_bufnr = nil
      end
      pcall(api.nvim_del_augroup_by_name, group_name)
    end,
  })

  api.nvim_create_autocmd('BufWipeout', {
    group = group,
    buffer = preview_bufnr,
    once = true,
    callback = function()
      clear_preview_var(source_bufnr, winnr)
      if active_preview_bufnr == preview_bufnr then
        active_preview_winnr = nil
        active_preview_bufnr = nil
      end
      pcall(api.nvim_del_augroup_by_name, group_name)
    end,
  })
end

local function open_below_preview_window(bufnr, source_winnr, height)
  -- Neovim 0.11+: nvim_open_win with split = "below" and win = -1 creates a
  -- full-width bottom split without changing the current window focus.
  local ok, preview_winnr = pcall(api.nvim_open_win, bufnr, false, {
    split = 'below',
    win = -1,
    height = height,
  })
  if ok and preview_winnr and preview_winnr ~= 0 then return preview_winnr end

  -- Fallback: botright split command (pre-0.11 or if nvim_open_win split fails)
  local current_winnr = api.nvim_get_current_win()

  if is_valid_win(source_winnr) then api.nvim_set_current_win(source_winnr) end

  local ok2, err = pcall(api.nvim_command, ('botright %dsplit'):format(height))
  if not ok2 then
    if is_valid_win(current_winnr) then api.nvim_set_current_win(current_winnr) end
    vim.notify(('Unable to open LSP preview split: %s'):format(err), vim.log.levels.WARN)
    return
  end

  preview_winnr = api.nvim_get_current_win()
  api.nvim_win_set_buf(preview_winnr, bufnr)
  return preview_winnr
end

---@diagnostic disable-next-line: duplicate-set-field
local function open_floating_preview(contents, syntax, opts)
  vim.validate('contents', contents, 'table')
  vim.validate('syntax', syntax, 'string', true)
  vim.validate('opts', opts, 'table', true)

  opts = opts or {}
  opts.wrap = opts.wrap ~= false
  opts.focus = opts.focus ~= false
  opts.close_events = opts.close_events -- or default_events

  local source_bufnr = api.nvim_get_current_buf()
  local source_winnr = api.nvim_get_current_win()
  local source_cursor = api.nvim_win_get_cursor(source_winnr)
  local source_view = vim.fn.winsaveview()
  local preview_winnr = opts._update_win
  local preview_bufnr ---@type integer?

  if preview_winnr then
    preview_bufnr = api.nvim_win_get_buf(preview_winnr)
  else
    preview_winnr, preview_bufnr = find_preview_window()

    if not (preview_bufnr and api.nvim_buf_is_valid(preview_bufnr)) then
      preview_bufnr = create_preview_buf()
      preview_winnr = nil
    end
  end

  if not preview_bufnr then return nil, nil end
  ---@cast preview_bufnr integer

  opts.width = preview_width()
  opts.height = preview_height()

  if opts.wrap then
    opts.wrap_at = opts.width
  else
    opts.wrap_at = nil
  end

  local preview_contents, do_stylize = normalize_contents(contents, syntax, opts)
  local height = opts.height

  set_preview_lines(preview_bufnr, preview_contents)

  if preview_winnr and is_valid_win(preview_winnr) then
    if api.nvim_win_get_height(preview_winnr) ~= height then win_set_height(preview_winnr, height) end
  else
    preview_winnr = open_below_preview_window(preview_bufnr, source_winnr, height)
    if not preview_winnr then return nil, nil end

    api.nvim_buf_set_keymap(preview_bufnr, 'n', 'q', '<cmd>close<cr>', { silent = true, noremap = true, nowait = true })
  end

  apply_window_options(preview_winnr, opts)
  apply_syntax(preview_bufnr, preview_winnr, syntax, do_stylize)

  local previous_source_bufnr = win_get_var(preview_winnr, 'lsp_floating_bufnr')
  if previous_source_bufnr and previous_source_bufnr ~= source_bufnr then
    clear_preview_var(previous_source_bufnr, preview_winnr)
    clear_hover_range(previous_source_bufnr)
  end

  active_preview_bufnr = preview_bufnr
  active_preview_winnr = preview_winnr

  api.nvim_buf_set_var(source_bufnr, 'lsp_floating_preview', preview_winnr)
  api.nvim_win_set_var(preview_winnr, 'lsp_floating_bufnr', source_bufnr)
  api.nvim_win_set_var(preview_winnr, 'util_lsp_preview', true)

  resize_for_conceal(preview_winnr, opts, do_stylize)

  if is_valid_win(source_winnr) then
    api.nvim_set_current_win(source_winnr)
    pcall(api.nvim_win_set_cursor, source_winnr, source_cursor)
    pcall(vim.fn.winrestview, source_view)
  end

  setup_close_autocmds(preview_winnr, preview_bufnr, source_bufnr)

  return preview_bufnr, preview_winnr
end

function M.setup() vim.lsp.util.open_floating_preview = open_floating_preview end

return M
