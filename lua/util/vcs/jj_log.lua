local api = vim.api
local exec = require('util.vcs.exec')
local win = require('util.win')

local M = {}
local state ---@type table?

local function anchored(s)
  return s.panel_win
    and s.panel_buf
    and api.nvim_win_is_valid(s.panel_win)
    and api.nvim_win_get_buf(s.panel_win) == s.panel_buf
end

local function current_row(s)
  if not (s.winnr and api.nvim_win_is_valid(s.winnr)) then return nil end
  local row = s.rows and s.rows[api.nvim_win_get_cursor(s.winnr)[1]]
  return row and row.revision and row or nil
end

local function selectable_line(s, start, direction)
  local line = start
  while line >= 1 and line <= #(s.rows or {}) do
    if s.rows[line].revision then return line end
    line = line + direction
  end
end

local function mark_count(s)
  local count = 0
  for _ in pairs(s.marks) do
    count = count + 1
  end
  return count
end

local function update_winbar(s)
  if state ~= s or not (s.winnr and api.nvim_win_is_valid(s.winnr)) then return end
  local suffix = s.loading and ' · loading…' or ''
  if s.action then suffix = suffix .. (' · %s…'):format(s.action) end
  local count = mark_count(s)
  if count > 0 then suffix = suffix .. (' · %d selected'):format(count) end
  pcall(
    api.nvim_set_option_value,
    'winbar',
    win.escape_statusline((' JJ log · %s%s '):format(s.revset, suffix)),
    { win = s.winnr }
  )
end

local function close_preview(s)
  if s.preview_timer then
    pcall(s.preview_timer.stop, s.preview_timer)
    pcall(s.preview_timer.close, s.preview_timer)
    s.preview_timer = nil
  end
  s.preview_gen = s.preview_gen + 1
  if s.preview_win and api.nvim_win_is_valid(s.preview_win) then pcall(api.nvim_win_close, s.preview_win, true) end
  if s.preview_buf and api.nvim_buf_is_valid(s.preview_buf) then
    pcall(api.nvim_buf_delete, s.preview_buf, { force = true })
  end
  s.preview_win, s.preview_buf = nil, nil
end

local function close(s, wiped)
  s = s or state
  if not s or state ~= s then return end
  state = nil
  s.gen = s.gen + 1
  close_preview(s)
  pcall(api.nvim_del_augroup_by_name, s.augroup)
  if s.winnr and api.nvim_win_is_valid(s.winnr) then pcall(api.nvim_win_close, s.winnr, true) end
  if not wiped and s.bufnr and api.nvim_buf_is_valid(s.bufnr) then
    pcall(api.nvim_buf_delete, s.bufnr, { force = true })
  end
  if anchored(s) then pcall(api.nvim_set_current_win, s.panel_win) end
end

local function set_cursor(s, line)
  if state ~= s or not (s.winnr and api.nvim_win_is_valid(s.winnr)) then return end
  local row = s.rows[line]
  if not (row and row.revision) then return end
  s.last_revision = row.revision
  pcall(api.nvim_win_set_cursor, s.winnr, { line, 0 })
end

local show_current

local function schedule_preview(s)
  if not (s.preview_win and api.nvim_win_is_valid(s.preview_win)) then return end
  -- Invalidate an in-flight preview immediately when the cursor changes;
  -- the debounced request below will claim a fresh generation.
  s.preview_gen = s.preview_gen + 1
  if s.preview_timer then
    pcall(s.preview_timer.stop, s.preview_timer)
    pcall(s.preview_timer.close, s.preview_timer)
  end
  local timer = vim.uv.new_timer()
  if not timer then return end
  s.preview_timer = timer
  timer:start(
    60,
    0,
    vim.schedule_wrap(function()
      pcall(timer.close, timer)
      if state == s and s.preview_timer == timer then
        s.preview_timer = nil
        show_current(s)
      end
    end)
  )
end

local function render(s)
  if state ~= s or not (s.bufnr and api.nvim_buf_is_valid(s.bufnr)) then return end
  local rows = {
    { text = ('JJ revisions · %s'):format(s.revset), hl = 'UtilVcsHeader' },
    {
      text = '  j/k navigate · Space select · d show · p preview · e edit · D describe · a new-after · ? help',
      hl = 'UtilVcsHelp',
    },
  }
  if s.show_help then
    vim.list_extend(rows, {
      {
        text = '  S squash · b bookmark · U undo · / search · n/N match · L revset · R refresh · q close',
        hl = 'UtilVcsHelp',
      },
      { text = '  Visual Line + Space selects a range; Visual Line + a creates a merge change', hl = 'UtilVcsHelp' },
      { text = '  gg/G first/last · Esc clear selection/close', hl = 'UtilVcsHelp' },
      { text = '  Enter/d opens the selected revision; an open preview follows the cursor', hl = 'UtilVcsHelp' },
    })
  end
  rows[#rows + 1] = { text = '' }
  for _, row in ipairs(s.data or {}) do
    rows[#rows + 1] = row
  end
  if #(s.data or {}) == 0 and not s.loading then
    rows[#rows + 1] = { text = '  No revisions in this revset', hl = 'UtilVcsHelp' }
  end

  local lines = vim.tbl_map(function(row) return row.text end, rows)
  pcall(api.nvim_set_option_value, 'modifiable', true, { buf = s.bufnr })
  api.nvim_buf_set_lines(s.bufnr, 0, -1, false, lines)
  pcall(api.nvim_set_option_value, 'modifiable', false, { buf = s.bufnr })
  api.nvim_buf_clear_namespace(s.bufnr, s.ns_id, 0, -1)
  for i, row in ipairs(rows) do
    if row.hl then
      pcall(api.nvim_buf_set_extmark, s.bufnr, s.ns_id, i - 1, 0, { end_col = #row.text, hl_group = row.hl })
    elseif not row.revision then
      pcall(api.nvim_buf_set_extmark, s.bufnr, s.ns_id, i - 1, 0, { end_col = #row.text, hl_group = 'Comment' })
    else
      pcall(api.nvim_buf_set_extmark, s.bufnr, s.ns_id, i - 1, 0, {
        end_col = #row.text,
        hl_group = row.working_copy and 'UtilVcsHeader' or 'UtilVcsCommit',
      })
      if row.graph_end and row.graph_end > 0 then
        pcall(api.nvim_buf_set_extmark, s.bufnr, s.ns_id, i - 1, 0, {
          end_col = row.graph_end,
          hl_group = 'UtilVcsGraph',
          priority = 60,
        })
      end
      if s.marks[row.revision] then
        pcall(api.nvim_buf_set_extmark, s.bufnr, s.ns_id, i - 1, 0, {
          sign_text = '✓',
          sign_hl_group = 'UtilVcsMarked',
          priority = 90,
        })
      end
    end
  end
  s.rows = rows

  local target
  if s.last_revision then
    for i, row in ipairs(rows) do
      if row.revision == s.last_revision then
        target = i
        break
      end
    end
  end
  target = target or selectable_line(s, 1, 1) or 1
  if rows[target] and rows[target].revision then s.last_revision = rows[target].revision end
  if s.winnr and api.nvim_win_is_valid(s.winnr) then pcall(api.nvim_win_set_cursor, s.winnr, { target, 0 }) end
  update_winbar(s)
end

local function refresh(s, revset)
  if state ~= s or not anchored(s) then
    close(s)
    return
  end
  s.gen = s.gen + 1
  local gen = s.gen
  local requested = revset or s.revset
  s.loading = true
  update_winbar(s)
  s.backend.log_data(s.root, requested, function(res, rows)
    if state ~= s or gen ~= s.gen then return end
    s.loading = false
    if not exec.report(res) then
      update_winbar(s)
      return
    end
    s.revset = requested
    s.data = rows or {}
    s.marks = {}
    render(s)
    schedule_preview(s)
  end)
end

local function set_preview_lines(s, lines)
  if not (s.preview_buf and api.nvim_buf_is_valid(s.preview_buf)) then return end
  pcall(api.nvim_set_option_value, 'modifiable', true, { buf = s.preview_buf })
  api.nvim_buf_set_lines(s.preview_buf, 0, -1, false, lines)
  pcall(api.nvim_set_option_value, 'modifiable', false, { buf = s.preview_buf })
end

local function ensure_preview(s)
  if s.preview_win and api.nvim_win_is_valid(s.preview_win) then return true end
  s.preview_buf = api.nvim_create_buf(false, true)
  pcall(api.nvim_set_option_value, 'bufhidden', 'wipe', { buf = s.preview_buf })
  pcall(api.nvim_set_option_value, 'buftype', 'nofile', { buf = s.preview_buf })
  pcall(api.nvim_set_option_value, 'swapfile', false, { buf = s.preview_buf })
  pcall(api.nvim_set_option_value, 'filetype', 'jj', { buf = s.preview_buf })
  local ok, preview_win = pcall(api.nvim_open_win, s.preview_buf, false, { split = 'right', win = s.winnr })
  if not ok then
    pcall(api.nvim_buf_delete, s.preview_buf, { force = true })
    s.preview_buf = nil
    return false
  end
  s.preview_win = preview_win
  for name, value in pairs({
    number = false,
    relativenumber = false,
    wrap = false,
    cursorline = false,
    signcolumn = 'no',
    spell = false,
  }) do
    pcall(api.nvim_set_option_value, name, value, { win = preview_win })
  end
  return true
end

show_current = function(s)
  if state ~= s then return end
  local row = current_row(s)
  if not row or not ensure_preview(s) then return end
  s.preview_gen = s.preview_gen + 1
  local gen = s.preview_gen
  set_preview_lines(s, { 'Loading ' .. row.revision:sub(1, 12) .. '…' })
  pcall(api.nvim_set_option_value, 'winbar', win.escape_statusline(' JJ show · loading… '), { win = s.preview_win })
  s.backend.show(s.root, row.revision, function(res)
    if state ~= s or gen ~= s.preview_gen or not anchored(s) then return end
    if not exec.report(res) then return end
    set_preview_lines(s, vim.split(res.stdout or '', '\n', { trimempty = true }))
    if s.preview_win and api.nvim_win_is_valid(s.preview_win) then
      pcall(
        api.nvim_set_option_value,
        'winbar',
        win.escape_statusline((' JJ show · %s '):format(row.revision:sub(1, 12))),
        { win = s.preview_win }
      )
    end
  end)
end

local function move(s, direction, edge)
  if state ~= s or not (s.winnr and api.nvim_win_is_valid(s.winnr)) then return end
  local current = api.nvim_win_get_cursor(s.winnr)[1]
  local start = edge == 'first' and 1 or edge == 'last' and #s.rows or current + direction
  local line = selectable_line(s, start, edge == 'last' and -1 or direction)
  if line then
    set_cursor(s, line)
    schedule_preview(s)
  end
end

local function search(s, direction, prompt)
  if state ~= s then return end
  local function apply(query)
    if state ~= s or not query or query == '' then return end
    s.search = query
    local needle = query:lower()
    local current = api.nvim_win_get_cursor(s.winnr)[1]
    for step = 1, #s.rows do
      local line = ((current - 1 + direction * step) % #s.rows) + 1
      local row = s.rows[line]
      if row.revision and row.text:lower():find(needle, 1, true) then
        set_cursor(s, line)
        schedule_preview(s)
        return
      end
    end
    vim.notify(('No JJ log match for %q'):format(query), vim.log.levels.INFO, { title = 'VCS' })
  end
  if prompt then
    vim.ui.input({ prompt = 'Search JJ log: ', default = s.search or '' }, apply)
  elseif s.search then
    apply(s.search)
  end
end

local function edit_revset(s)
  if state ~= s then return end
  vim.ui.input({ prompt = 'JJ revset: ', default = s.revset }, function(value)
    value = value and vim.trim(value) or nil
    if state == s and value and value ~= '' then refresh(s, value) end
  end)
end

local function selected_revisions(s)
  local revisions = {}
  if next(s.marks) then
    for _, row in ipairs(s.rows) do
      if row.revision and s.marks[row.revision] then revisions[#revisions + 1] = row.revision end
    end
  else
    local row = current_row(s)
    if row then revisions[1] = row.revision end
  end
  return revisions
end

local function single_revision(s, action)
  local revisions = selected_revisions(s)
  if #revisions == 1 then return revisions[1] end
  vim.notify(('%s requires exactly one JJ revision'):format(action), vim.log.levels.WARN, { title = 'VCS' })
end

local function run_mutation(s, label, invoke)
  if state ~= s or s.action then return end
  if exec.busy[s.root] then
    vim.notify('VCS operation in progress: ' .. exec.busy[s.root], vim.log.levels.WARN, { title = 'VCS' })
    return
  end
  s.action = label
  exec.busy[s.root] = label
  s.preview_gen = s.preview_gen + 1
  update_winbar(s)
  local completed = false
  local function done(res)
    if completed then return end
    completed = true
    if exec.busy[s.root] == label then exec.busy[s.root] = nil end
    if state ~= s then return end
    s.action = nil
    if not exec.report(res, label .. ' complete') then
      update_winbar(s)
      return
    end
    s.marks = {}
    if s.on_change then pcall(s.on_change) end
    refresh(s)
  end
  local ok, err = pcall(invoke, done)
  if not ok then done({ code = -1, stdout = '', stderr = tostring(err) }) end
end

local function action(s, name)
  if state ~= s or s.action then return end
  if name == 'edit' then
    local revision = single_revision(s, 'Edit')
    if revision then run_mutation(s, 'Edit revision', function(done) s.backend.edit(s.root, revision, done) end) end
  elseif name == 'describe' then
    local revision = single_revision(s, 'Describe')
    if not revision then return end
    vim.ui.input({ prompt = 'Change description: ' }, function(message)
      if state == s and message and message ~= '' then
        run_mutation(s, 'Describe revision', function(done) s.backend.commit(s.root, message, done, revision) end)
      end
    end)
  elseif name == 'new' then
    local revisions = selected_revisions(s)
    if #revisions == 0 then return end
    local prompt = #revisions == 1 and 'Create a new change after this revision?'
      or ('Create a merge change with %d parents?'):format(#revisions)
    if vim.fn.confirm(prompt, '&Create\n&Cancel', 2) == 1 then
      run_mutation(s, 'Create change', function(done) s.backend.new_change(s.root, done, revisions) end)
    end
  elseif name == 'squash' then
    local revision = single_revision(s, 'Squash')
    if revision and vim.fn.confirm('Squash this revision into its parent?', '&Squash\n&Cancel', 2) == 1 then
      run_mutation(s, 'Squash revision', function(done) s.backend.squash(s.root, done, revision) end)
    end
  elseif name == 'bookmark' then
    local revision = single_revision(s, 'Bookmark')
    if not revision then return end
    vim.ui.input({ prompt = 'Bookmark name: ' }, function(name_value)
      name_value = name_value and vim.trim(name_value) or nil
      if state == s and name_value and name_value ~= '' then
        run_mutation(s, 'Set bookmark', function(done) s.backend.bookmark(s.root, name_value, revision, done) end)
      end
    end)
  elseif name == 'undo' then
    if vim.fn.confirm('Undo the last JJ operation?', '&Undo\n&Cancel', 2) == 1 then
      run_mutation(s, 'Undo operation', function(done) s.backend.undo(s.root, done) end)
    end
  end
end

local function visual_marks(s, first, last)
  first, last = math.min(first, last), math.max(first, last)
  s.marks = {}
  for line = first, last do
    local row = s.rows[line]
    if row and row.revision then s.marks[row.revision] = true end
  end
  render(s)
end

---@param opts { root: string, panel_win: integer, panel_buf: integer, backend: table, revset: string?, on_change: fun()? }
function M.open(opts)
  if state then close(state) end
  if
    not (
      opts.panel_win
      and opts.panel_buf
      and api.nvim_win_is_valid(opts.panel_win)
      and api.nvim_win_get_buf(opts.panel_win) == opts.panel_buf
    )
  then
    return
  end

  local s = {
    root = opts.root,
    panel_win = opts.panel_win,
    panel_buf = opts.panel_buf,
    backend = opts.backend,
    on_change = opts.on_change,
    revset = opts.revset or 'all()',
    data = {},
    rows = {},
    marks = {},
    gen = 0,
    preview_gen = 0,
    ns_id = api.nvim_create_namespace('util.vcs.jj_log'),
  }
  state = s
  s.bufnr = api.nvim_create_buf(false, true)
  pcall(api.nvim_set_option_value, 'bufhidden', 'wipe', { buf = s.bufnr })
  pcall(api.nvim_set_option_value, 'buftype', 'nofile', { buf = s.bufnr })
  pcall(api.nvim_set_option_value, 'swapfile', false, { buf = s.bufnr })
  pcall(api.nvim_set_option_value, 'modifiable', false, { buf = s.bufnr })
  pcall(api.nvim_set_option_value, 'filetype', 'jjlog', { buf = s.bufnr })
  s.winnr = win.open_bottom(s.bufnr, { height = math.max(math.floor(vim.o.lines / 2), 12), win = s.panel_win })
  if not s.winnr then
    state = nil
    pcall(api.nvim_buf_delete, s.bufnr, { force = true })
    return
  end

  for name, value in pairs({
    number = false,
    relativenumber = false,
    wrap = false,
    cursorline = true,
    signcolumn = 'auto:1',
    foldenable = false,
    spell = false,
    winfixheight = true,
  }) do
    pcall(api.nvim_set_option_value, name, value, { win = s.winnr })
  end

  local function keymap(lhs, rhs)
    api.nvim_buf_set_keymap(s.bufnr, 'n', lhs, rhs, { noremap = true, silent = true, nowait = true })
  end
  keymap('q', '<Cmd>lua require("util.vcs.jj_log").close()<CR>')
  keymap('<Esc>', '<Cmd>lua require("util.vcs.jj_log")._cancel()<CR>')
  keymap('j', '<Cmd>lua require("util.vcs.jj_log")._move(1)<CR>')
  keymap('k', '<Cmd>lua require("util.vcs.jj_log")._move(-1)<CR>')
  keymap('<C-n>', '<Cmd>lua require("util.vcs.jj_log")._move(1)<CR>')
  keymap('<C-p>', '<Cmd>lua require("util.vcs.jj_log")._move(-1)<CR>')
  keymap('gg', '<Cmd>lua require("util.vcs.jj_log")._edge("first")<CR>')
  keymap('G', '<Cmd>lua require("util.vcs.jj_log")._edge("last")<CR>')
  keymap('<Space>', '<Cmd>lua require("util.vcs.jj_log")._toggle()<CR>')
  keymap('<CR>', '<Cmd>lua require("util.vcs.jj_log")._show()<CR>')
  keymap('d', '<Cmd>lua require("util.vcs.jj_log")._show()<CR>')
  keymap('p', '<Cmd>lua require("util.vcs.jj_log")._preview()<CR>')
  keymap('/', '<Cmd>lua require("util.vcs.jj_log")._search()<CR>')
  keymap('n', '<Cmd>lua require("util.vcs.jj_log")._search_next(1)<CR>')
  keymap('N', '<Cmd>lua require("util.vcs.jj_log")._search_next(-1)<CR>')
  keymap('L', '<Cmd>lua require("util.vcs.jj_log")._revset()<CR>')
  keymap('R', '<Cmd>lua require("util.vcs.jj_log")._refresh()<CR>')
  keymap('<C-r>', '<Cmd>lua require("util.vcs.jj_log")._refresh()<CR>')
  keymap('?', '<Cmd>lua require("util.vcs.jj_log")._help()<CR>')
  keymap('e', '<Cmd>lua require("util.vcs.jj_log")._action("edit")<CR>')
  keymap('D', '<Cmd>lua require("util.vcs.jj_log")._action("describe")<CR>')
  keymap('a', '<Cmd>lua require("util.vcs.jj_log")._action("new")<CR>')
  keymap('S', '<Cmd>lua require("util.vcs.jj_log")._action("squash")<CR>')
  keymap('b', '<Cmd>lua require("util.vcs.jj_log")._action("bookmark")<CR>')
  keymap('U', '<Cmd>lua require("util.vcs.jj_log")._action("undo")<CR>')
  api.nvim_buf_set_keymap(
    s.bufnr,
    'x',
    '<Space>',
    ':<C-u>lua require("util.vcs.jj_log")._visual_toggle()<CR>',
    { noremap = true, silent = true, nowait = true }
  )
  api.nvim_buf_set_keymap(
    s.bufnr,
    'x',
    'a',
    ':<C-u>lua require("util.vcs.jj_log")._visual_action("new")<CR>',
    { noremap = true, silent = true, nowait = true }
  )

  s.augroup = ('util.vcs.jj_log.%d'):format(s.bufnr)
  local group = api.nvim_create_augroup(s.augroup, { clear = true })
  api.nvim_create_autocmd('CursorMoved', {
    group = group,
    buffer = s.bufnr,
    callback = function()
      if state ~= s then return end
      local row = current_row(s)
      if row then
        s.last_revision = row.revision
        schedule_preview(s)
      end
    end,
  })
  api.nvim_create_autocmd('BufWipeout', {
    group = group,
    buffer = s.bufnr,
    callback = function()
      if state == s then close(s, true) end
    end,
  })
  api.nvim_create_autocmd('BufWipeout', {
    group = group,
    buffer = s.panel_buf,
    callback = function()
      if state == s then close(s) end
    end,
  })

  render(s)
  refresh(s)
end

function M.close() close(state) end
function M._move(direction)
  if state then move(state, direction) end
end
function M._edge(edge)
  if state then move(state, edge == 'last' and -1 or 1, edge) end
end
function M._toggle()
  local s = state
  local row = s and current_row(s)
  if not row then return end
  s.marks[row.revision] = not s.marks[row.revision] or nil
  render(s)
end
function M._cancel()
  if not state then return end
  if next(state.marks) then
    state.marks = {}
    render(state)
  else
    close(state)
  end
end
function M._show()
  if state then show_current(state) end
end
function M._preview()
  if not state then return end
  if state.preview_win and api.nvim_win_is_valid(state.preview_win) then
    close_preview(state)
  else
    show_current(state)
  end
end
function M._search()
  if state then search(state, 1, true) end
end
function M._search_next(direction)
  if state then search(state, direction, false) end
end
function M._revset()
  if state then edit_revset(state) end
end
function M._refresh()
  if state then refresh(state) end
end
function M._help()
  if not state then return end
  state.show_help = not state.show_help
  render(state)
end
function M._action(name)
  if state then action(state, name) end
end
function M._visual_toggle(first, last)
  if not state then return end
  visual_marks(state, first or vim.fn.line("'<"), last or vim.fn.line("'>"))
end
function M._visual_action(name, first, last)
  if not state then return end
  visual_marks(state, first or vim.fn.line("'<"), last or vim.fn.line("'>"))
  action(state, name)
end

return M
