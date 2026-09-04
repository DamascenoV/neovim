local api = vim.api
local win = require('util.win')

local M = {}

local state ---@type table?

local function get_permissions(path)
  local stat = vim.uv.fs_stat(path)
  if not stat then return '----------' end

  local mode = stat.mode
  local perms = ''

  if stat.type == 'directory' then
    perms = 'd'
  elseif stat.type == 'link' then
    perms = 'l'
  else
    perms = '-'
  end

  perms = perms .. (math.floor(mode / 256) % 2 == 1 and 'r' or '-') -- 0x100
  perms = perms .. (math.floor(mode / 128) % 2 == 1 and 'w' or '-') -- 0x080
  perms = perms .. (math.floor(mode / 64) % 2 == 1 and 'x' or '-') -- 0x040

  perms = perms .. (math.floor(mode / 32) % 2 == 1 and 'r' or '-') -- 0x020
  perms = perms .. (math.floor(mode / 16) % 2 == 1 and 'w' or '-') -- 0x010
  perms = perms .. (math.floor(mode / 8) % 2 == 1 and 'x' or '-') -- 0x008

  perms = perms .. (math.floor(mode / 4) % 2 == 1 and 'r' or '-') -- 0x004
  perms = perms .. (math.floor(mode / 2) % 2 == 1 and 'w' or '-') -- 0x002
  perms = perms .. (mode % 2 == 1 and 'x' or '-') -- 0x001

  return perms
end

local function format_size(size)
  if size < 1024 then
    return string.format('%4d', size)
  elseif size < 1024 * 1024 then
    return string.format('%3.1fK', size / 1024)
  elseif size < 1024 * 1024 * 1024 then
    return string.format('%3.1fM', size / (1024 * 1024))
  else
    return string.format('%3.1fG', size / (1024 * 1024 * 1024))
  end
end

local function format_mtime(mtime_sec)
  if not mtime_sec then return '           ' end

  local current_time = os.time()
  local time_diff = current_time - mtime_sec

  if time_diff < 6 * 30 * 24 * 60 * 60 then
    return os.date('%b %d %H:%M', mtime_sec)
  else
    return os.date('%b %d  %Y', mtime_sec)
  end
end

local function ls_prefix(path)
  local stat = vim.uv.fs_stat(path)
  if not stat then return '' end
  return string.format(
    '%s %8s %s ',
    get_permissions(path),
    format_size(stat.size or 0),
    format_mtime(stat.mtime and stat.mtime.sec)
  )
end

local function list_dir(path)
  local s = state
  local ok, entries = pcall(vim.uv.fs_scandir, path)
  if not ok or not entries then return {} end

  local names = {}
  while true do
    local name, type = vim.uv.fs_scandir_next(entries)
    if not name then break end
    -- Hide dotfiles unless the user toggled them on with `.`
    if s.show_hidden or name:sub(1, 1) ~= '.' then
      names[#names + 1] = { name = name, type = type or (vim.uv.fs_stat(vim.fs.joinpath(path, name)) or {}).type }
    end
  end

  table.sort(names, function(a, b)
    local a_dir = a.type == 'directory'
    local b_dir = b.type == 'directory'
    if a_dir ~= b_dir then return a_dir end
    return a.name:lower() < b.name:lower()
  end)

  return names
end

local function current_row()
  local s = state
  if not (s and s.winnr and api.nvim_win_is_valid(s.winnr)) then return end
  local line = api.nvim_win_get_cursor(s.winnr)[1]
  return s.rows[line]
end

local function update_winbar()
  local s = state
  if not (s and s.winnr and api.nvim_win_is_valid(s.winnr)) then return end
  local hidden_note = s.show_hidden and '' or ' (dotfiles hidden)'
  pcall(
    api.nvim_set_option_value,
    'winbar',
    win.escape_statusline((' ' .. s.root .. hidden_note .. ' ')),
    { win = s.winnr }
  )
end

local function render()
  local s = state
  if not (s and s.bufnr and api.nvim_buf_is_valid(s.bufnr)) then return end

  s.rows = {}
  local lines, meta_extents = {}, {}
  for i, entry in ipairs(list_dir(s.root)) do
    local entry_path = vim.fs.joinpath(s.root, entry.name)
    local meta = ls_prefix(entry_path)
    local is_dir = entry.type == 'directory'
    s.rows[i] = { path = entry_path, name = entry.name, type = entry.type }
    meta_extents[i] = { 0, #meta }
    lines[i] = meta .. entry.name .. (is_dir and '/' or '')
  end

  api.nvim_buf_clear_namespace(s.bufnr, s.ns_id, 0, -1)
  pcall(api.nvim_set_option_value, 'modifiable', true, { buf = s.bufnr })
  api.nvim_buf_set_lines(s.bufnr, 0, -1, false, lines)
  pcall(api.nvim_set_option_value, 'modifiable', false, { buf = s.bufnr })

  for i, extent in ipairs(meta_extents) do
    if extent[2] > extent[1] then
      pcall(api.nvim_buf_set_extmark, s.bufnr, s.ns_id, i - 1, extent[1], {
        end_col = extent[2],
        hl_group = 'UtilExplorerMeta',
        priority = 60,
      })
    end
    local row = s.rows[i]
    pcall(api.nvim_buf_set_extmark, s.bufnr, s.ns_id, i - 1, extent[2], {
      end_col = #lines[i],
      hl_group = row.type == 'directory' and 'UtilExplorerDirectory' or 'UtilExplorerFile',
      priority = 50,
    })
  end

  update_winbar()
end

---@param reason 'open'|'dismissed'
local function close(reason)
  local s = state
  if not s then return end
  state = nil

  if s.bufnr and api.nvim_buf_is_valid(s.bufnr) then pcall(api.nvim_buf_delete, s.bufnr, { force = true }) end
  if s.winnr and api.nvim_win_is_valid(s.winnr) then pcall(api.nvim_win_close, s.winnr, true) end
  pcall(api.nvim_del_augroup_by_name, s.augroup_name)

  if reason == 'dismissed' and s.source_winnr and api.nvim_win_is_valid(s.source_winnr) then
    pcall(api.nvim_set_current_win, s.source_winnr)
  end
end

local function open_file(path)
  local s = state
  local source_winnr = s and s.source_winnr
  close('open')

  if source_winnr and api.nvim_win_is_valid(source_winnr) then pcall(api.nvim_set_current_win, source_winnr) end
  local ok = pcall(vim.cmd.edit, vim.fn.fnameescape(path))
  if not ok then vim.notify(('Unable to open %s'):format(path), vim.log.levels.WARN) end
end

local function go_in()
  local s = state
  local row = current_row()
  if not row then return end

  if row.type == 'directory' then
    s.root = row.path
    render()
    pcall(api.nvim_win_set_cursor, s.winnr, { 1, 0 })
    return
  end

  open_file(row.path)
end

local function go_out()
  local s = state
  if not s then return end
  local parent = vim.fs.dirname(s.root)
  if parent == s.root then return end
  s.root = parent
  render()
  pcall(api.nvim_win_set_cursor, s.winnr, { 1, 0 })
end

local function cursor_to_path(path)
  local s = state
  if not s then return end
  for i, row in ipairs(s.rows) do
    if row.path == path then
      pcall(api.nvim_win_set_cursor, s.winnr, { i, 0 })
      return
    end
  end
end

--- lstat-based existence: also catches dangling symlinks (fs_stat misses them)
local function path_exists(path) return vim.uv.fs_lstat(path) ~= nil end

local function create_entry()
  local s = state
  local base_dir = s.root

  vim.ui.input({ prompt = ('New entry in %s (append / for directory): '):format(base_dir) }, function(input)
    if not input or input == '' then return end
    if state ~= s then return end -- explorer closed or reopened while prompting

    local is_dir = input:sub(-1) == '/'
    local name = input:gsub('/+$', '')
    if name == '' then return end

    -- Single-level entries only (the trailing / marks a directory): no nested
    -- paths, so nothing can traverse symlinked intermediate directories
    if name:find('/', 1, true) then
      vim.notify('Create failed: create one level at a time (no nested paths)', vim.log.levels.WARN)
      return
    end
    if name == '..' or name == '.' then
      vim.notify('Create failed: path traversal (..) is not allowed', vim.log.levels.ERROR)
      return
    end

    local path = vim.fs.joinpath(base_dir, name)
    if path_exists(path) then
      vim.notify(('Already exists: %s'):format(path), vim.log.levels.WARN)
      return
    end

    local ok, err
    if is_dir then
      ok, err = pcall(vim.fn.mkdir, path, 'p')
      if ok and vim.uv.fs_stat(path) == nil then
        ok, err = false, 'mkdir reported success but directory is missing'
      end
    else
      ok, err = pcall(vim.fn.mkdir, vim.fs.dirname(path), 'p')
      if ok then
        local write_ok, write_ret = pcall(vim.fn.writefile, {}, path)
        if not write_ok or write_ret ~= 0 then
          ok, err = false, ('writefile failed: %s'):format(tostring(write_ret))
        end
      end
    end
    if not ok or vim.uv.fs_stat(path) == nil then
      vim.notify(('Create failed: %s'):format(err or 'unknown error'), vim.log.levels.ERROR)
      return
    end

    render()
    cursor_to_path(path)
  end)
end

local function delete_entry()
  local s = state
  local row = current_row()
  if not row then return end

  local answer = vim.fn.confirm(('Delete %s?'):format(row.path), '&Delete\n&Cancel', 2)
  if answer ~= 1 then return end

  local ok, ret = pcall(vim.fn.delete, row.path, row.type == 'directory' and 'rf' or '')
  if not ok then
    vim.notify(('Delete failed: %s'):format(tostring(ret)), vim.log.levels.ERROR)
    return
  end
  if ret ~= 0 then
    vim.notify(('Delete failed: code %d'):format(ret), vim.log.levels.ERROR)
    return
  end
  if path_exists(row.path) then
    vim.notify('Delete failed: path still exists', vim.log.levels.ERROR)
    return
  end

  render()
end

local function rename_entry()
  local s = state
  local row = current_row()
  if not row then return end

  vim.ui.input({ prompt = 'Rename to: ', default = row.name }, function(input)
    if not input or input == '' or input == row.name then return end
    if state ~= s then return end -- explorer closed or reopened while prompting

    -- Plain name only: renaming never moves entries between directories
    if input:find('/', 1, true) then
      vim.notify('Rename failed: use a plain name (no paths)', vim.log.levels.WARN)
      return
    end

    local target = vim.fs.joinpath(vim.fs.dirname(row.path), input)
    if path_exists(target) then
      vim.notify(('Rename failed: %s already exists'):format(target), vim.log.levels.WARN)
      return
    end

    local ok, ret = pcall(vim.fn.rename, row.path, target)
    if not ok then
      vim.notify(('Rename failed: %s'):format(tostring(ret)), vim.log.levels.ERROR)
      return
    end
    if ret ~= 0 then
      vim.notify(('Rename failed: code %d'):format(ret), vim.log.levels.ERROR)
      return
    end
    if vim.uv.fs_stat(row.path) or not vim.uv.fs_stat(target) then
      vim.notify('Rename failed: filesystem state unexpected', vim.log.levels.ERROR)
      return
    end

    render()
    cursor_to_path(target)
  end)
end

local function keymap(lhs, rhs, desc)
  api.nvim_buf_set_keymap(state.bufnr, 'n', lhs, rhs, { noremap = true, silent = true, nowait = true, desc = desc })
end

--- Open the flat directory listing at `path` (defaults to cwd).
function M.open(path)
  if state then close('dismissed') end

  path = path and path ~= '' and path or '.'
  if vim.uv.fs_stat(path) and vim.uv.fs_stat(path).type ~= 'directory' then path = vim.fs.dirname(path) end
  path = vim.fn.resolve(vim.fn.expand(path))

  local s = {
    root = path,
    source_winnr = api.nvim_get_current_win(),
    show_hidden = true,
    rows = {},
    ns_id = api.nvim_create_namespace('util.explorer'),
  }
  state = s

  s.bufnr = api.nvim_create_buf(false, true)
  pcall(api.nvim_set_option_value, 'bufhidden', 'wipe', { buf = s.bufnr })
  pcall(api.nvim_set_option_value, 'buftype', 'nofile', { buf = s.bufnr })
  pcall(api.nvim_set_option_value, 'swapfile', false, { buf = s.bufnr })
  pcall(api.nvim_set_option_value, 'modifiable', false, { buf = s.bufnr })

  -- +1 line: the winbar occupies one content row of the window
  s.winnr = win.open_bottom(s.bufnr, { height = win.list_height() + 1 })
  if not s.winnr then
    state = nil
    error('Explorer: unable to open bottom split')
  end

  local win_opts = {
    number = false,
    relativenumber = false,
    signcolumn = 'no',
    cursorline = true,
    foldenable = false,
    wrap = false,
    spell = false,
    winfixheight = true,
  }
  for name, value in pairs(win_opts) do
    pcall(api.nvim_set_option_value, name, value, { win = s.winnr })
  end

  s.augroup_name = ('util.explorer.%d'):format(s.bufnr)
  local group = api.nvim_create_augroup(s.augroup_name, { clear = true })
  api.nvim_create_autocmd('WinClosed', {
    group = group,
    pattern = tostring(s.winnr),
    callback = function()
      if state ~= s then return end
      close('dismissed')
    end,
  })
  api.nvim_create_autocmd('BufWipeout', {
    group = group,
    buffer = s.bufnr,
    callback = function()
      if state ~= s then return end
      close('dismissed')
    end,
  })

  keymap('<CR>', '<Cmd>lua require("util.explorer")._go_in()<CR>', 'Open file / enter dir')
  keymap('l', '<Cmd>lua require("util.explorer")._go_in()<CR>', 'Open / enter dir')
  keymap('L', '<Cmd>lua require("util.explorer")._go_in()<CR>', 'Open / enter dir')
  keymap('h', '<Cmd>lua require("util.explorer")._go_out()<CR>', 'Parent dir')
  keymap('-', '<Cmd>lua require("util.explorer")._go_out()<CR>', 'Root to parent')
  keymap('H', '<Cmd>lua require("util.explorer")._go_out()<CR>', 'Root to parent')
  keymap('a', '<Cmd>lua require("util.explorer")._create()<CR>', 'Create file/dir')
  keymap('D', '<Cmd>lua require("util.explorer")._delete()<CR>', 'Delete entry')
  keymap('r', '<Cmd>lua require("util.explorer")._rename()<CR>', 'Rename entry')
  keymap('R', '<Cmd>lua require("util.explorer")._refresh()<CR>', 'Refresh')
  keymap('.', '<Cmd>lua require("util.explorer")._toggle_hidden()<CR>', 'Toggle dotfiles')
  keymap('g.', '<Cmd>lua require("util.explorer")._toggle_hidden()<CR>', 'Toggle dotfiles')
  keymap('gX', '<Cmd>lua require("util.explorer")._os_open()<CR>', 'OS open')
  keymap('q', '<Cmd>lua require("util.explorer").close()<CR>', 'Close explorer')
  keymap('<C-c>', '<Cmd>lua require("util.explorer").close()<CR>', 'Close explorer')

  render()
end

function M.close() close('dismissed') end

function M._go_in() go_in() end
function M._go_out() go_out() end
function M._create() create_entry() end
function M._delete() delete_entry() end
function M._rename() rename_entry() end
function M._refresh() render() end

function M._toggle_hidden()
  local s = state
  if not s then return end
  s.show_hidden = not s.show_hidden
  render()
end

function M._os_open()
  local row = current_row()
  if row then vim.ui.open(row.path) end
end

return M
