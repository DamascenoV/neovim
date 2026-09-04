---Native VCS status panel (neogit-style) with git and jj backends.
local api = vim.api
local exec = require('util.vcs.exec')

local M = {}

---@class VcsFile
---@field path string repository-root-relative
---@field display string? rendered path (renames show "new <- old")
---@field code string status code (git XY column or jj MADRCC?)
---@field staged boolean? git only: file appears in the staged section
---@field untracked boolean? git only: file is untracked
---@field old_path string? renames/copies: source path
---@field copy boolean? jj copies: old_path still exists after the copy

---@class VcsSection
---@field kind string 'staged' | 'unstaged' | 'untracked' | 'conflicts' | 'working'
---@field title string
---@field files VcsFile[]

---@class VcsStatus
---@field header string
---@field sections VcsSection[]

---@class VcsRow
---@field kind string 'header' | 'help' | 'section' | 'file' | 'blank'
---@field text string
---@field hl string?
---@field code_hl { from: integer, to: integer, group: string }?
---@field file VcsFile?
---@field section VcsSection?

local prefer ---@type 'git' | 'jj'?
local state ---@type table?

local CODE_HL = {
  M = 'UtilVcsModified',
  A = 'UtilVcsAdded',
  D = 'UtilVcsDeleted',
  R = 'UtilVcsRenamed',
  C = 'UtilVcsRenamed',
  U = 'UtilVcsConflict',
  T = 'UtilVcsModified',
  ['?'] = 'UtilVcsUntracked',
}

---Pick the active backend: explicit `prefer` if its repo is present,
---then jj (colocated repos default to jj when the binary exists), then git.
---@return table? backend
local function detect()
  if prefer == 'git' or prefer == 'jj' then
    local candidate = require('util.vcs.' .. prefer)
    if candidate.available() then return candidate end
  end
  local jj = require('util.vcs.jj')
  if jj.available() and vim.fn.executable('jj') == 1 then return jj end
  local git = require('util.vcs.git')
  if git.available() then return git end
  return nil
end

-- ---------------------------------------------------------------------------
-- Rendering

---@param status VcsStatus
---@param backend table
---@return VcsRow[]
local function build_rows(status, backend)
  local rows = {}
  local function add(row) rows[#rows + 1] = row end

  add({ kind = 'header', text = status.header, hl = 'UtilVcsHeader' })
  add({ kind = 'help', text = backend.help, hl = 'UtilVcsHelp' })

  for _, section in ipairs(status.sections) do
    add({ kind = 'blank', text = '' })
    add({ kind = 'section', text = ('%s (%d)'):format(section.title, #section.files), hl = 'UtilVcsSection' })
    for _, file in ipairs(section.files) do
      local code = file.code or ''
      add({
        kind = 'file',
        text = ('  %s  %s'):format(code, file.display or file.path),
        code_hl = { from = 2, to = 2 + #code, group = CODE_HL[code] or 'UtilVcsModified' },
        file = file,
        section = section,
      })
    end
  end

  if #status.sections == 0 then
    add({ kind = 'blank', text = '' })
    add({ kind = 'blank', text = 'Working tree clean', hl = 'UtilVcsHelp' })
  end

  return rows
end

---@param s table
---@param status VcsStatus
local function render(s, status)
  local rows = build_rows(status, s.backend)
  local lines = {}
  for i, row in ipairs(rows) do
    lines[i] = row.text
  end

  local bufnr = s.bufnr
  pcall(api.nvim_set_option_value, 'modifiable', true, { buf = bufnr })
  api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  pcall(api.nvim_set_option_value, 'modifiable', false, { buf = bufnr })

  api.nvim_buf_clear_namespace(bufnr, s.ns_id, 0, -1)
  for i, row in ipairs(rows) do
    local line = i - 1
    if row.hl then
      pcall(api.nvim_buf_set_extmark, bufnr, s.ns_id, line, 0, { end_col = #row.text, hl_group = row.hl })
    end
    if row.code_hl and row.kind == 'file' then
      pcall(api.nvim_buf_set_extmark, bufnr, s.ns_id, line, row.code_hl.from, {
        end_col = row.code_hl.to,
        hl_group = row.code_hl.group,
      })
    end
  end

  s.rows = rows

  -- Keep the cursor on the previously selected file when it survives a refresh
  local target = 1
  local prev = s.last_file
  if prev then
    for i, row in ipairs(rows) do
      if row.kind == 'file' and row.file.path == prev.path then
        target = i
        break
      end
    end
  end
  if s.winnr and api.nvim_win_is_valid(s.winnr) then
    pcall(api.nvim_win_set_cursor, s.winnr, { math.min(target, #rows), 0 })
  end
end

---Collect status asynchronously; only the newest request renders, so a slow
---collect from a stale action can never overwrite a newer one.
---@param s table
local function refresh(s)
  s.gen = s.gen + 1
  local gen = s.gen
  s.backend.collect(s.root, function(status)
    if state ~= s or gen ~= s.gen then return end
    if not status then return end
    render(s, status)
  end)
end

-- ---------------------------------------------------------------------------
-- Actions

---@param s table
---@return VcsFile? file
---@return VcsSection? section
local function current_file(s)
  if not (s.winnr and api.nvim_win_is_valid(s.winnr)) then return end
  local row = s.rows and s.rows[api.nvim_win_get_cursor(s.winnr)[1]]
  if row and row.file then return row.file, row.section end
end

---@param s table
local function not_supported(s)
  vim.notify(('Action not supported by %s'):format(s.backend.name), vim.log.levels.WARN, { title = 'VCS' })
end

---@param s table
local function act_open(s)
  local file = current_file(s)
  if not file then return end
  -- status paths are repo-root-relative; edit the absolute path so a changed
  -- cwd cannot resolve it against the wrong directory
  local path = s.root .. '/' .. file.path
  M.close()
  vim.cmd.edit(vim.fn.fnameescape(path))
end

---Open `lines` in a scratch vsplit anchored to the panel window (no-op once
---the panel is gone, so a slow command never writes into an unrelated window).
---@param s table
---@param lines string[]
---@param filetype string
local function open_scratch_split(s, lines, filetype)
  if state ~= s then return end
  if not (s.winnr and api.nvim_win_is_valid(s.winnr)) then return end

  local buf = api.nvim_create_buf(false, true)
  pcall(api.nvim_set_option_value, 'bufhidden', 'wipe', { buf = buf })
  pcall(api.nvim_set_option_value, 'buftype', 'nofile', { buf = buf })
  pcall(api.nvim_set_option_value, 'swapfile', false, { buf = buf })
  pcall(api.nvim_set_option_value, 'filetype', filetype, { buf = buf })
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local ok, winnr = pcall(api.nvim_open_win, buf, true, { split = 'right', win = s.winnr })
  if not ok then
    pcall(api.nvim_buf_delete, buf, { force = true })
    vim.notify(('Unable to open diff split: %s'):format(winnr), vim.log.levels.WARN, { title = 'VCS' })
  end
end

---@param s table
local function act_diff(s)
  local file = current_file(s)
  if not file then return end
  local cmd = s.backend.diff_cmd(s.root, file)
  if not cmd then
    vim.notify('No diff available for untracked files', vim.log.levels.WARN, { title = 'VCS' })
    return
  end
  exec.run(cmd, s.root, function(res)
    local ok = res.code == 0
    local text = vim.split(ok and (res.stdout or '') or (res.stderr or ''), '\n', { trimempty = true })
    if not ok then
      exec.report(res)
      return
    end
    if #text == 0 then
      vim.notify(('No changes for %s'):format(file.path), vim.log.levels.INFO, { title = 'VCS' })
      return
    end
    open_scratch_split(s, text, 'diff')
  end)
end

---@param s table
---@param action 'stage'|'unstage'|'stage_all'
local function act_simple(s, action)
  local backend = s.backend
  if action == 'stage_all' then
    if not backend.stage_all then return not_supported(s) end
    backend.stage_all(s.root, function(res)
      exec.report(res)
      refresh(s)
    end)
    return
  end

  if not backend[action] then return not_supported(s) end
  local file, section = current_file(s)
  if not file then return end

  -- validate the section the cursor is on: staging a staged row would pick up
  -- unrelated worktree changes, unstaging an unstaged row is a silent no-op
  if action == 'stage' and section.kind == 'staged' then
    vim.notify('Already staged', vim.log.levels.INFO, { title = 'VCS' })
    return
  elseif action == 'unstage' and section.kind ~= 'staged' then
    vim.notify('Not staged', vim.log.levels.INFO, { title = 'VCS' })
    return
  end

  backend[action](s.root, file.path, function(res)
    exec.report(res)
    refresh(s)
  end)
end

---@param s table
local function act_discard(s)
  local file = current_file(s)
  if not file then return end
  if not s.backend.discard then return not_supported(s) end
  local choice = vim.fn.confirm(('Discard changes in %s?'):format(file.path), '&Yes\n&No', 2)
  if choice ~= 1 then return end
  s.backend.discard(s.root, file, function(res)
    exec.report(res)
    refresh(s)
  end)
end

---@param s table
local function act_commit(s)
  s.backend.commit(s.root, function(res)
    exec.report(res, s.backend.name == 'jj' and 'Change described' or 'Committed')
    refresh(s)
  end)
end

local ACTS = {
  open = act_open,
  diff = act_diff,
  stage = function(s) act_simple(s, 'stage') end,
  unstage = function(s) act_simple(s, 'unstage') end,
  stage_all = function(s) act_simple(s, 'stage_all') end,
  discard = act_discard,
  commit = act_commit,
  push = function(s)
    s.backend.push(s.root, function(res)
      exec.report(res, 'Pushed')
      refresh(s)
    end)
  end,
  pull = function(s)
    s.backend.pull(s.root, function(res)
      exec.report(res, 'Fetched/pulled')
      refresh(s)
    end)
  end,
  new = function(s)
    if not s.backend.new_change then return not_supported(s) end
    s.backend.new_change(s.root, function(res)
      exec.report(res)
      refresh(s)
    end)
  end,
  squash = function(s)
    if not s.backend.squash then return not_supported(s) end
    s.backend.squash(s.root, function(res)
      exec.report(res)
      refresh(s)
    end)
  end,
  log = function(s)
    if not s.backend.log then return not_supported(s) end
    s.backend.log(s.root, s.winnr)
  end,
  refresh = function(s) refresh(s) end,
}

---Run a named action on the panel under the cursor (used by buffer keymaps).
---@param name string
function M._act(name)
  local s = state
  if not s then return end
  local fn = ACTS[name]
  if fn then fn(s) end
end

-- ---------------------------------------------------------------------------
-- Panel lifecycle

---@param s table
---@param wiped boolean true when called from the buffer's own BufWipeout
---(the buffer is already going away; skip window restore and deletion)
local function close(s, wiped)
  if state ~= s then return end
  state = nil

  pcall(api.nvim_del_augroup_by_name, s.augroup_name)

  if not wiped then
    if s.winnr and api.nvim_win_is_valid(s.winnr) then
      if s.prev_buf and api.nvim_buf_is_valid(s.prev_buf) then
        pcall(api.nvim_win_set_buf, s.winnr, s.prev_buf)
      else
        pcall(vim.cmd.enew)
      end
      -- restore the window-local options the panel overrode
      for name, value in pairs(s.prev_win_opts) do
        pcall(api.nvim_set_option_value, name, value, { win = s.winnr })
      end
    end
    pcall(api.nvim_buf_delete, s.bufnr, { force = true })
  end
end

function M.close()
  if state then close(state) end
end

---Open the VCS panel in the current window (restores the previous buffer on close).
function M.open()
  local backend = detect()
  if not backend then
    vim.notify('Not inside a git or jj repository', vim.log.levels.WARN, { title = 'VCS' })
    return
  end
  if state then close(state) end

  local root = vim.fs.root('.', { '.git', '.jj' })
  if not root then
    vim.notify('Unable to locate the repository root', vim.log.levels.WARN, { title = 'VCS' })
    return
  end

  local s = {
    backend = backend,
    bufnr = api.nvim_create_buf(false, true),
    ns_id = api.nvim_create_namespace('util.vcs'),
    rows = {},
    gen = 0,
    root = root,
    prev_buf = api.nvim_get_current_buf(),
    winnr = api.nvim_get_current_win(),
    prev_win_opts = {},
  }
  state = s

  pcall(api.nvim_set_option_value, 'bufhidden', 'wipe', { buf = s.bufnr })
  pcall(api.nvim_set_option_value, 'buftype', 'nofile', { buf = s.bufnr })
  pcall(api.nvim_set_option_value, 'swapfile', false, { buf = s.bufnr })
  pcall(api.nvim_set_option_value, 'modifiable', false, { buf = s.bufnr })

  api.nvim_win_set_buf(s.winnr, s.bufnr)

  local win_opts = {
    number = false,
    relativenumber = false,
    spell = false,
    wrap = false,
    cursorline = false,
    signcolumn = 'no',
    foldenable = false,
  }
  for name, value in pairs(win_opts) do
    s.prev_win_opts[name] = api.nvim_get_option_value(name, { win = s.winnr })
    pcall(api.nvim_set_option_value, name, value, { win = s.winnr })
  end

  local function keymap(lhs, rhs)
    api.nvim_buf_set_keymap(s.bufnr, 'n', lhs, rhs, { noremap = true, silent = true, nowait = true })
  end
  keymap('q', '<Cmd>lua require("util.vcs").close()<CR>')
  keymap('<CR>', '<Cmd>lua require("util.vcs")._act("open")<CR>')
  keymap('d', '<Cmd>lua require("util.vcs")._act("diff")<CR>')
  keymap('s', '<Cmd>lua require("util.vcs")._act("stage")<CR>')
  keymap('u', '<Cmd>lua require("util.vcs")._act("unstage")<CR>')
  keymap('a', '<Cmd>lua require("util.vcs")._act("stage_all")<CR>')
  keymap('-', '<Cmd>lua require("util.vcs")._act("discard")<CR>')
  keymap('c', '<Cmd>lua require("util.vcs")._act("commit")<CR>')
  keymap('n', '<Cmd>lua require("util.vcs")._act("new")<CR>')
  keymap('S', '<Cmd>lua require("util.vcs")._act("squash")<CR>')
  keymap('p', '<Cmd>lua require("util.vcs")._act("pull")<CR>')
  keymap('P', '<Cmd>lua require("util.vcs")._act("push")<CR>')
  keymap('L', '<Cmd>lua require("util.vcs")._act("log")<CR>')
  keymap('R', '<Cmd>lua require("util.vcs")._act("refresh")<CR>')

  s.augroup_name = 'util.vcs.' .. s.bufnr
  local group = api.nvim_create_augroup(s.augroup_name, { clear = true })
  api.nvim_create_autocmd('BufWipeout', {
    group = group,
    buffer = s.bufnr,
    callback = function() close(s, true) end,
  })
  api.nvim_create_autocmd('CursorMoved', {
    group = group,
    buffer = s.bufnr,
    callback = function()
      if state ~= s then return end
      local file = current_file(s)
      if file then s.last_file = file end
    end,
  })

  refresh(s)
end

---Set up user commands. `opts.prefer` forces a backend ('git' or 'jj') when
---its repository type is detected; otherwise jj wins in colocated repos.
---@param opts { prefer: 'git'|'jj' }?
function M.setup(opts)
  opts = opts or {}
  prefer = opts.prefer

  api.nvim_create_user_command('VCS', function() M.open() end, { desc = 'Open the VCS panel' })
end

return M
