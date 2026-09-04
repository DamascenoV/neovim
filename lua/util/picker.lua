local api = vim.api
local win = require('util.win')

local M = {}

local PROMPT_PREFIX = '> '
local WATCH_DEBOUNCE_MS = 120

local state ---@type table?

---@class UtilPickerCtx
---@field set_items fun(items: any[]): set the full item list (engine filters locally)
---@field watch fun(fn: fun(query: string, ctx: UtilPickerCtx)): register a live-query callback (debounced)
---@field is_active fun(): boolean
---@field get_query fun(): string
---@field close fun()

--- Normalize one item into a display entry.
local function to_entry(item, format)
  local text
  if type(item) == 'string' then
    text = item
  elseif type(item) == 'table' then
    text = item.text or (format and format(item) or nil)
  end
  return { text = text or tostring(item), item = item }
end

local function clear_extmarks()
  if not (state and state.bufnr and api.nvim_buf_is_valid(state.bufnr)) then return end
  api.nvim_buf_clear_namespace(state.bufnr, state.ns_id, 0, -1)
end

local function update_winbar()
  local s = state
  if not (s and s.winnr and api.nvim_win_is_valid(s.winnr)) then return end
  local marked = 0
  for _ in pairs(s.marks) do
    marked = marked + 1
  end
  local title = (' %s ─ %d/%d results%s '):format(
    s.title,
    #s.filtered,
    #s.items,
    marked > 0 and (' · %d marked'):format(marked) or ''
  )
  pcall(api.nvim_set_option_value, 'winbar', win.escape_statusline(title), { win = s.winnr })
end

-- ---------------------------------------------------------------------------
-- Preview (mini.pick-style <S-Tab> toggle; shows the selected item's file)

--- 1-based character column (in `encoding`) -> 1-based byte column.
-- Prefers a loaded buffer (shows unsaved edits), falls back to the file.
function M.char_col_to_byte(path, lnum, col, encoding)
  local line
  local bufnr = vim.fn.bufnr(path)
  if bufnr ~= -1 and api.nvim_buf_is_loaded(bufnr) then
    line = api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
  else
    local ok, lines = pcall(vim.fn.readfile, path, '', lnum)
    line = ok and lines and lines[lnum] or nil
  end
  if not line then return col end
  local ok2, byte = pcall(vim.str_byteindex, line, encoding or 'utf-16', col - 1, false)
  if ok2 and byte and byte >= 0 then return byte + 1 end
  return col
end

local function ensure_scratch(s)
  if s.preview_scratch and api.nvim_buf_is_valid(s.preview_scratch) then return s.preview_scratch end
  local pbuf = api.nvim_create_buf(false, true)
  pcall(api.nvim_set_option_value, 'bufhidden', 'wipe', { buf = pbuf })
  pcall(api.nvim_set_option_value, 'buftype', 'nofile', { buf = pbuf })
  pcall(api.nvim_set_option_value, 'swapfile', false, { buf = pbuf })
  s.preview_scratch = pbuf
  return pbuf
end

local function close_preview(s)
  if not s then return end
  if s.preview_winnr and api.nvim_win_is_valid(s.preview_winnr) then
    pcall(api.nvim_win_close, s.preview_winnr, true)
  end
  if s.preview_scratch and api.nvim_buf_is_valid(s.preview_scratch) then
    pcall(api.nvim_buf_delete, s.preview_scratch, { force = true })
  end
  s.preview_winnr = nil
  s.preview_scratch = nil
end

local function update_preview(s)
  if not (s and s.preview_winnr and api.nvim_win_is_valid(s.preview_winnr)) then return end

  local entry = s.filtered[s.selected]
  local item = entry and entry.item

  -- Table items that carry a real buffer: preview that buffer directly
  if type(item) == 'table' and item.bufnr and api.nvim_buf_is_valid(item.bufnr) then
    pcall(api.nvim_win_set_buf, s.preview_winnr, item.bufnr)
    pcall(api.nvim_win_set_cursor, s.preview_winnr, { item.lnum or 1, math.max((item.col or 1) - 1, 0) })
    return
  end

  -- Scratch preview for paths / plain text. Re-attach the scratch buffer in
  -- case a previous selection switched the preview to a real buffer.
  local pbuf = ensure_scratch(s)
  if api.nvim_win_get_buf(s.preview_winnr) ~= pbuf then pcall(api.nvim_win_set_buf, s.preview_winnr, pbuf) end

  local path = type(item) == 'table' and item.path or nil
  local lnum = type(item) == 'table' and item.lnum or 1
  local col = type(item) == 'table' and item.col or 1
  if type(item) == 'table' and item.char_col and path and item.lnum then
    col = M.char_col_to_byte(path, item.lnum, col, item.char_encoding)
  end

  local contents
  if path then
    local read_ok, read_lines = pcall(vim.fn.readfile, path, '', math.max((lnum or 1) + 50, 200))
    contents = read_ok and read_lines or { ('Unable to read %s'):format(path) }
  else
    contents = { entry and entry.text or '' }
  end

  pcall(api.nvim_buf_set_lines, pbuf, 0, -1, false, contents)
  api.nvim_buf_clear_namespace(pbuf, s.ns_id, 0, -1)
  if lnum >= 1 and lnum <= #contents then
    pcall(api.nvim_buf_set_extmark, pbuf, s.ns_id, lnum - 1, 0, {
      line_hl_group = 'UtilPickerPreviewLine',
      priority = 50,
    })
  end
  local ft = path and vim.filetype.match({ filename = path }) or nil
  pcall(api.nvim_set_option_value, 'filetype', ft or '', { buf = pbuf })
  pcall(api.nvim_win_set_cursor, s.preview_winnr, { math.min(lnum, #contents), math.max(col - 1, 0) })
end

local function toggle_preview()
  local s = state
  if not s then return end

  if s.preview_winnr and api.nvim_win_is_valid(s.preview_winnr) then
    close_preview(s)
    return
  end

  ensure_scratch(s)

  -- Vertical split to the right of the picker window (fzf-style preview pane)
  local ok, winnr = pcall(api.nvim_open_win, s.preview_scratch, false, {
    split = 'right',
    win = s.winnr,
  })
  if not ok or not winnr or winnr == 0 then
    close_preview(s)
    return
  end
  s.preview_winnr = winnr

  local preview_opts = {
    number = false,
    relativenumber = false,
    wrap = false,
    cursorline = false,
    signcolumn = 'no',
    spell = false,
    winfixheight = true,
  }
  for name, value in pairs(preview_opts) do
    pcall(api.nvim_set_option_value, name, value, { win = winnr })
  end
  pcall(api.nvim_set_option_value, 'winbar', win.escape_statusline(' preview '), { win = winnr })

  update_preview(s)
end

--- Render a fixed-height results viewport above the pinned bottom prompt.
-- The buffer always has exactly `s.height` lines: results slice + blank
-- padding + prompt as the last line, so the prompt never moves when the
-- result count changes. s.offset scrolls the viewport for long lists.
local function render()
  local s = state
  if not (s and s.bufnr and api.nvim_buf_is_valid(s.bufnr)) then return end

  local visible = math.max((s.height or win.list_height()) - 1, 1)

  -- Keep the selection inside the viewport and the offset in range
  local max_offset = math.max(0, #s.filtered - visible)
  if s.selected < s.offset + 1 then s.offset = s.selected - 1 end
  if s.selected > s.offset + visible then s.offset = s.selected - visible end
  s.offset = math.max(0, math.min(s.offset, max_offset))

  clear_extmarks()

  local first = s.offset + 1
  local last = math.min(s.offset + visible, #s.filtered)
  local lines = {}
  for i = first, last do
    lines[#lines + 1] = s.filtered[i].text
  end
  while #lines < visible do
    lines[#lines + 1] = ''
  end

  -- Replace every row above the prompt; the prompt stays as the last line
  local old_count = api.nvim_buf_line_count(s.bufnr) - 1
  pcall(api.nvim_buf_set_lines, s.bufnr, 0, old_count, false, lines)

  -- Selected row highlight (buffer row = index - offset, 0-based)
  if s.selected >= first and s.selected <= last then
    pcall(api.nvim_buf_set_extmark, s.bufnr, s.ns_id, s.selected - first, 0, {
      line_hl_group = 'UtilPickerCurrent',
      priority = 50,
    })
  end

  -- Fuzzy match highlights: merge consecutive positions into runs.
  -- Positions are character indices; skip non-ASCII rows to avoid byte/char
  -- column mismatch in extmarks.
  if s.positions then
    for i = first, last do
      local positions = s.positions[i]
      local text = s.filtered[i].text
      if positions and #positions > 0 and text:find('[^%z\1-\127]') == nil then
        local buf_row = i - first
        local run_start = positions[1]
        local prev = positions[1]
        for p = 2, #positions do
          local col = positions[p]
          if col ~= prev + 1 then
            pcall(api.nvim_buf_set_extmark, s.bufnr, s.ns_id, buf_row, run_start, {
              end_col = prev + 1,
              hl_group = 'UtilPickerMatched',
              priority = 60,
            })
            run_start = col
          end
          prev = col
        end
        pcall(api.nvim_buf_set_extmark, s.bufnr, s.ns_id, buf_row, run_start, {
          end_col = prev + 1,
          hl_group = 'UtilPickerMatched',
          priority = 60,
        })
      end
    end
  end

  -- Marks (sign column)
  for idx in pairs(s.marks) do
    if idx >= first and idx <= last then
      pcall(api.nvim_buf_set_extmark, s.bufnr, s.ns_id, idx - first, 0, {
        sign_text = '◆',
        sign_hl_group = 'UtilPickerMarked',
        priority = 90,
      })
    end
  end

  -- Prompt prefix highlight (prompt is the last buffer line)
  pcall(api.nvim_buf_set_extmark, s.bufnr, s.ns_id, visible, 0, {
    end_col = #PROMPT_PREFIX,
    hl_group = 'UtilPickerPrompt',
    priority = 70,
  })

  -- Pin the cursor to the prompt row (buffer height is fixed at s.height)
  if s.winnr and api.nvim_win_is_valid(s.winnr) and api.nvim_get_current_win() == s.winnr then
    local cursor = api.nvim_win_get_cursor(s.winnr)
    if cursor[1] ~= s.height then
      pcall(api.nvim_win_set_cursor, s.winnr, { s.height, math.max(cursor[2], #PROMPT_PREFIX) })
    end
  end

  update_winbar()
  update_preview(s)
end

local function apply_filter()
  local s = state
  local q = s.query

  if q == '' or not s.filter then
    s.filtered = s.entries
    s.positions = nil
  else
    local ok, res = pcall(vim.fn.matchfuzzypos, s.entries, q, { key = 'text' })
    if ok and type(res) == 'table' and res[1] and #res[1] > 0 then
      s.filtered = res[1]
      s.positions = res[2]
    else
      s.filtered = {}
      s.positions = nil
    end
  end

  if s.selected > math.max(#s.filtered, 1) then s.selected = math.max(#s.filtered, 1) end
end

local function cancel_watch_timer(s)
  local timer = s.watch_timer
  if not timer then return end
  s.watch_timer = nil
  pcall(function()
    timer:stop()
    timer:close()
  end)
end

local function notify_watchers(s)
  if not s then return end

  cancel_watch_timer(s)
  local timer = vim.uv.new_timer()
  s.watch_timer = timer
  timer:start(
    WATCH_DEBOUNCE_MS,
    0,
    vim.schedule_wrap(function()
      pcall(timer.close, timer)
      if state == s and s.watch_timer == timer then
        s.watch_timer = nil
        for _, fn in ipairs(s.watchers) do
          fn(s.query, s.ctx)
        end
      end
    end)
  )
end

local function on_query_changed(from_user)
  local s = state
  if not s then return end

  if from_user and s.bufnr and api.nvim_buf_is_valid(s.bufnr) then
    local total = api.nvim_buf_line_count(s.bufnr)
    local line = api.nvim_buf_get_lines(s.bufnr, total - 1, total, false)[1] or PROMPT_PREFIX

    -- The prompt is the LAST buffer line of a fixed-height buffer. A damaged
    -- prefix (backspace/x past it) or a multiline paste breaks that layout:
    -- rebuild it, keeping the query intact.
    if line:sub(1, #PROMPT_PREFIX) ~= PROMPT_PREFIX or total ~= s.height then
      local initial = {}
      for _ = 1, (s.height or 2) - 1 do
        initial[#initial + 1] = ''
      end
      initial[#initial + 1] = PROMPT_PREFIX .. s.query
      pcall(api.nvim_buf_set_lines, s.bufnr, 0, -1, false, initial)
      render() -- redraw the results viewport above the rebuilt prompt
      return
    end

    local query = line:sub(#PROMPT_PREFIX + 1)
    if query == s.query then
      -- Programmatic re-render (nvim_buf_set_lines during insert mode fires
      -- TextChangedI): not a real query edit, keep selection and marks intact.
      return
    end
    s.query = query
  end

  s.marks = {}
  s.selected = 1
  s.offset = 0
  apply_filter()
  render()
  notify_watchers(s)
end

---@param reason 'chosen'|'dismissed'
local function close(reason)
  local s = state
  if not s then return end
  state = nil

  cancel_watch_timer(s)
  close_preview(s)
  if s.bufnr and api.nvim_buf_is_valid(s.bufnr) then pcall(api.nvim_buf_delete, s.bufnr, { force = true }) end
  if s.winnr and api.nvim_win_is_valid(s.winnr) then pcall(api.nvim_win_close, s.winnr, true) end
  pcall(api.nvim_del_augroup_by_name, s.augroup_name)

  if s.source_winnr and api.nvim_win_is_valid(s.source_winnr) then pcall(api.nvim_set_current_win, s.source_winnr) end
  if s.on_teardown then pcall(s.on_teardown) end
  if reason == 'dismissed' and s.on_close then pcall(s.on_close) end
end

local function choose()
  local s = state
  if not s then return end
  local entry = s.filtered[s.selected]
  if not entry then return end

  local on_choose = s.on_choose
  close('chosen')
  if on_choose then on_choose(entry.item) end
end

local function set_prompt(text)
  local s = state
  if not (s and s.bufnr and api.nvim_buf_is_valid(s.bufnr)) then return end
  s.query = text
  local total = api.nvim_buf_line_count(s.bufnr)
  pcall(api.nvim_buf_set_lines, s.bufnr, total - 1, total, false, { PROMPT_PREFIX .. text })
  if s.winnr and api.nvim_win_is_valid(s.winnr) then
    pcall(api.nvim_win_set_cursor, s.winnr, { total, #PROMPT_PREFIX + #text })
  end
  on_query_changed(false)
end

local function toggle_mark()
  local s = state
  if not s then return end
  local entry = s.filtered[s.selected]
  if not entry then return end
  if s.marks[s.selected] then
    s.marks[s.selected] = nil
  else
    s.marks[s.selected] = true
  end
  render()
end

local function send_to_quickfix()
  local s = state
  if not s then return end

  local chosen = {}
  for i, entry in ipairs(s.filtered) do
    if s.marks[i] then chosen[#chosen + 1] = entry end
  end
  if #chosen == 0 then chosen = s.filtered end

  local qf_items = {}
  for _, entry in ipairs(chosen) do
    local item = entry.item
    if type(item) == 'table' and item.path then
      local col = item.col or 1
      if item.char_col and item.lnum then col = M.char_col_to_byte(item.path, item.lnum, col, item.char_encoding) end
      qf_items[#qf_items + 1] = {
        filename = item.path,
        lnum = item.lnum or 1,
        col = col,
        text = entry.text,
      }
    end
  end

  local title = s.title
  close('dismissed')
  if #qf_items == 0 then
    vim.notify('Picker: no items with a file path to send to the quickfix', vim.log.levels.INFO)
    return
  end
  vim.fn.setqflist(qf_items, ' ', { title = title })
  vim.cmd('botright copen')
end

--- Public: replace the item list. `items` are raw source items (strings or tables).
function M.set_items(items)
  local s = state
  if not s then return end

  s.items = items or {}
  s.entries = {}
  s.marks = {} -- marks are index-based; a new item list invalidates them
  for i, item in ipairs(s.items) do
    s.entries[i] = to_entry(item, s.format)
  end
  apply_filter()
  render()
end

function M.move(delta)
  local s = state
  if not s then return end
  local count = math.max(#s.filtered, 1)
  s.selected = math.min(math.max(s.selected + delta, 1), count)
  render()
end

--- Open the picker.
---@param opts {
---  title: string?,            winbar title
---  query: string?,            initial query
---  filter: boolean?,          apply local fuzzy filtering (default true; disable for live sources)
---  format: (fun(item): string)?,
---  on_choose: fun(item: any)?,
---  on_close: fun()?,
---  on_teardown: fun()?,          runs on every close (choose or dismiss)
---  delete_action: fun(item: any)?,
---}
---@return UtilPickerCtx
function M.open(opts)
  if state then close('dismissed') end

  opts = opts or {}
  local s = {
    title = opts.title or 'Pick',
    query = opts.query or '',
    filter = opts.filter ~= false,
    format = opts.format,
    on_choose = opts.on_choose,
    on_close = opts.on_close,
    on_teardown = opts.on_teardown,
    delete_action = opts.delete_action,
    items = {},
    entries = {},
    filtered = {},
    positions = nil,
    marks = {},
    selected = 1,
    offset = 0,
    height = nil,
    watchers = {},
    ns_id = api.nvim_create_namespace('util.picker'),
  }
  state = s

  s.bufnr = api.nvim_create_buf(false, true)
  pcall(api.nvim_set_option_value, 'bufhidden', 'wipe', { buf = s.bufnr })
  pcall(api.nvim_set_option_value, 'buftype', 'nofile', { buf = s.bufnr })
  pcall(api.nvim_set_option_value, 'swapfile', false, { buf = s.bufnr })

  s.source_winnr = api.nvim_get_current_win()
  -- +1 line: the winbar (title + results counter) occupies one content row
  s.winnr = win.open_bottom(s.bufnr, { height = win.list_height() + 1 })
  if not s.winnr then
    state = nil
    error('Picker: unable to open bottom split')
  end

  local win_opts = {
    number = false,
    relativenumber = false,
    signcolumn = 'auto:1',
    cursorline = false,
    foldenable = false,
    wrap = false,
    spell = false,
    winfixheight = true,
  }
  for name, value in pairs(win_opts) do
    pcall(api.nvim_set_option_value, name, value, { win = s.winnr })
  end
  -- Fixed layout: buffer always has exactly s.height lines, so the bottom
  -- prompt never moves when the result count changes. The winbar takes one
  -- visible row, so content rows = window height - 1.
  s.height = math.max(api.nvim_win_get_height(s.winnr) - 1, 2)
  local initial = {}
  for _ = 1, s.height - 1 do
    initial[#initial + 1] = ''
  end
  initial[#initial + 1] = PROMPT_PREFIX .. s.query
  update_winbar()

  s.augroup_name = ('util.picker.%d'):format(s.bufnr)
  local group = api.nvim_create_augroup(s.augroup_name, { clear = true })
  api.nvim_create_autocmd('TextChangedI', {
    group = group,
    buffer = s.bufnr,
    callback = function()
      if state ~= s then return end
      on_query_changed(true)
    end,
  })
  api.nvim_create_autocmd('CursorMovedI', {
    group = group,
    buffer = s.bufnr,
    callback = function()
      if state ~= s then return end
      -- Keep the cursor on the prompt (last line), past the prefix
      local total = api.nvim_buf_line_count(s.bufnr)
      local cursor = api.nvim_win_get_cursor(s.winnr)
      if cursor[1] ~= total or cursor[2] < #PROMPT_PREFIX then
        pcall(api.nvim_win_set_cursor, s.winnr, { total, math.max(cursor[2], #PROMPT_PREFIX) })
      end
    end,
  })
  api.nvim_create_autocmd('WinClosed', {
    group = group,
    pattern = tostring(s.winnr),
    callback = function()
      if state == s then close('dismissed') end
    end,
  })
  api.nvim_create_autocmd('BufWipeout', {
    group = group,
    buffer = s.bufnr,
    callback = function()
      if state == s then close('dismissed') end
    end,
  })

  local function keymap(mode, lhs, rhs)
    api.nvim_buf_set_keymap(s.bufnr, mode, lhs, rhs, { noremap = true, silent = true, nowait = true })
  end

  -- Normal-mode keys run plain commands; insert-mode keys exit insert for
  -- session-changing actions and stay in insert for prompt-only actions.
  keymap('n', '<CR>', '<Cmd>lua require("util.picker")._choose_current()<CR>')
  keymap('n', '<Esc>', '<Cmd>lua require("util.picker").close()<CR>')
  keymap('n', '<C-n>', '<Cmd>lua require("util.picker").move(1)<CR>')
  keymap('n', '<C-p>', '<Cmd>lua require("util.picker").move(-1)<CR>')
  keymap('n', 'j', '<Cmd>lua require("util.picker").move(1)<CR>')
  keymap('n', 'k', '<Cmd>lua require("util.picker").move(-1)<CR>')
  keymap('n', '<Tab>', '<Cmd>lua require("util.picker")._toggle_mark()<CR>')
  keymap('n', '<C-q>', '<Cmd>lua require("util.picker")._quickfix()<CR>')
  keymap('n', '<C-d>', '<Cmd>lua require("util.picker")._delete_current()<CR>')
  keymap('n', '<C-u>', '<Cmd>lua require("util.picker")._clear_query()<CR>')
  keymap('i', '<CR>', '<Esc><Cmd>lua require("util.picker")._choose_current()<CR>')
  keymap('i', '<C-c>', '<Esc><Cmd>lua require("util.picker").close()<CR>')
  keymap('i', '<Esc>', '<Esc><Cmd>lua require("util.picker").close()<CR>')
  keymap('i', '<C-n>', '<Cmd>lua require("util.picker").move(1)<CR>')
  keymap('i', '<C-p>', '<Cmd>lua require("util.picker").move(-1)<CR>')
  keymap('i', '<Down>', '<Cmd>lua require("util.picker").move(1)<CR>')
  keymap('i', '<Up>', '<Cmd>lua require("util.picker").move(-1)<CR>')
  keymap('i', '<C-u>', '<Cmd>lua require("util.picker")._clear_query()<CR>')
  -- Mark/delete actions re-enter insert so the picker stays usable
  keymap('i', '<Tab>', '<Esc><Cmd>lua require("util.picker")._toggle_mark()<CR><Cmd>startinsert<CR>')
  keymap('i', '<C-q>', '<Esc><Cmd>lua require("util.picker")._quickfix()<CR>')
  keymap('i', '<C-d>', '<Esc><Cmd>lua require("util.picker")._delete_current()<CR><Cmd>startinsert<CR>')
  keymap('n', '<S-Tab>', '<Cmd>lua require("util.picker")._toggle_preview()<CR>')
  keymap('i', '<S-Tab>', '<Cmd>lua require("util.picker")._toggle_preview()<CR>')

  api.nvim_buf_set_lines(s.bufnr, 0, -1, false, initial)
  if opts.items ~= nil then
    M.set_items(opts.items)
  else
    on_query_changed(false)
  end

  s.ctx = {
    set_items = function(items)
      if state ~= s then return end
      M.set_items(items)
    end,
    watch = function(fn) table.insert(s.watchers, fn) end,
    is_active = function() return state == s end,
    get_query = function() return state == s and s.query or '' end,
    close = function()
      if state == s then close('dismissed') end
    end,
  }

  pcall(api.nvim_set_current_win, s.winnr)
  -- The prompt is the last buffer line; place the cursor after the prefix
  local total = api.nvim_buf_line_count(s.bufnr)
  pcall(api.nvim_win_set_cursor, s.winnr, { total, #PROMPT_PREFIX + #s.query })
  vim.cmd('startinsert!')

  return s.ctx
end

function M.close() close('dismissed') end

-- Plug targets used by the buffer-local keymaps
function M._choose_current() choose() end
function M._clear_query() set_prompt('') end
function M._toggle_mark() toggle_mark() end
function M._quickfix() send_to_quickfix() end
function M._toggle_preview() toggle_preview() end

function M._delete_current()
  local s = state
  local entry = s and s.filtered[s.selected]
  if not (s and entry and s.delete_action) then return end
  s.delete_action(entry.item)
end

--- vim.ui.select implementation on top of the picker.
function M.ui_select(items, opts, on_choice)
  opts = opts or {}
  local wrapped = {}
  for i, value in ipairs(items) do
    local label = opts.format_item and opts.format_item(value) or tostring(value)
    wrapped[i] = { text = ('%d. %s'):format(i, label), value = value, idx = i }
  end

  M.open({
    title = opts.prompt or 'Select one of',
    items = wrapped,
    on_choose = function(item) on_choice(item.value, item.idx) end,
    on_close = function() on_choice(nil, nil) end,
  })
end

function M.setup()
  vim.ui.select = M.ui_select

  api.nvim_create_user_command('Pick', function(o)
    local sources = require('util.picker_sources')
    local name, query = o.fargs[1], nil
    if #o.fargs > 1 then query = table.concat(o.fargs, ' ', 2) end

    local source = sources.get(name)
    if not source then
      local available = vim.tbl_keys(sources.all())
      table.sort(available)
      vim.notify(
        ('Unknown Pick source "%s". Available: %s'):format(name, table.concat(available, ', ')),
        vim.log.levels.ERROR
      )
      return
    end
    source.start({ query = query })
  end, {
    nargs = '+',
    complete = function(_, line)
      local sources = require('util.picker_sources')
      local arg = vim.split(vim.trim(line), '%s+')[2] or ''
      return vim.tbl_filter(function(key) return key:find(arg, 1, true) == 1 end, vim.tbl_keys(sources.all()))
    end,
    desc = 'Open the native picker',
  })
end

return M
