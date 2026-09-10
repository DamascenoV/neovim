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

local function target_key(file, section) return section.kind .. '\0' .. file.path end

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

---@param s table
---@param status VcsStatus
---@param backend table
---@return VcsRow[]
local function build_rows(s, status, backend)
  local rows = {}
  local function add(row) rows[#rows + 1] = row end

  local busy = exec.busy[s.root]
  add({ kind = 'header', text = status.header .. (busy and (' · ' .. busy .. '…') or ''), hl = 'UtilVcsHeader' })
  add({ kind = 'help', text = '  ' .. backend.help, hl = 'UtilVcsHelp' })
  add({ kind = 'blank', text = '' })

  for si, section in ipairs(status.sections) do
    if si > 1 then add({ kind = 'blank', text = '' }) end
    local collapsed = s.collapsed[section.kind]
    local title = ('▎ %s'):format(section.title)
    if collapsed then
      add({
        kind = 'section',
        text = ('%s (%d) ⋯'):format(title, #section.files),
        hl = 'UtilVcsSection',
        section = section,
      })
    else
      add({
        kind = 'section',
        text = ('%s (%d)'):format(title, #section.files),
        hl = 'UtilVcsSection',
        section = section,
      })
      for _, file in ipairs(section.files) do
        local code = file.code or ''
        add({
          kind = 'file',
          text = ('  %s  %s'):format(code, file.display or file.path),
          code_hl = { from = 2, to = 2 + #code, group = CODE_HL[code] or 'UtilVcsModified' },
          file = file,
          section = section,
        })
        local expanded = s.hunks[target_key(file, section)]
        if expanded then
          for _, hunk in ipairs(expanded.items) do
            for _, line in ipairs(hunk.lines) do
              local hl = line:match('^@@') and 'DiffChange'
                or line:match('^%+') and 'DiffAdd'
                or line:match('^%-') and 'DiffDelete'
                or 'Comment'
              add({
                kind = 'hunk',
                text = '    ' .. line,
                hl = hl,
                file = file,
                section = section,
                hunk = hunk,
                raw = expanded.raw,
              })
            end
          end
        end
      end
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
  local rows = build_rows(s, status, s.backend)
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
    -- selection marks (sign column)
    if row.file and s.marks[target_key(row.file, row.section)] then
      pcall(api.nvim_buf_set_extmark, bufnr, s.ns_id, line, 0, {
        sign_text = '◆',
        sign_hl_group = 'UtilVcsMarked',
        priority = 90,
      })
    end
  end

  s.rows = rows

  -- Keep the cursor on the previously selected file when it survives a refresh
  local target = 1
  local prev = s.last_key
  if prev then
    for i, row in ipairs(rows) do
      if row.kind == 'file' and target_key(row.file, row.section) == prev then
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
  if state ~= s then return end
  if exec.busy[s.root] then return end
  s.gen = s.gen + 1
  local gen = s.gen
  s.backend.collect(s.root, function(status)
    if state ~= s or gen ~= s.gen then return end
    if not status then return end
    s.last_status = status
    s.hunks = {}
    -- A path can occur in both staged and unstaged sections.
    local keep = {}
    for _, section in ipairs(status.sections) do
      for _, file in ipairs(section.files) do
        keep[target_key(file, section)] = true
      end
    end
    for path in pairs(s.marks) do
      if not keep[path] then s.marks[path] = nil end
    end
    render(s, status)
  end)
end

---Briefly highlight the rows for `paths` (action feedback).
---@param s table
---@param paths table<string, boolean>
local function flash_rows(s, paths)
  if not (s.bufnr and api.nvim_buf_is_valid(s.bufnr)) then return end
  local ns = api.nvim_create_namespace('util.vcs.flash')
  for i, row in ipairs(s.rows or {}) do
    if row.file and paths[row.file.path] then
      pcall(api.nvim_buf_set_extmark, s.bufnr, ns, i - 1, 0, {
        end_col = #row.text,
        hl_group = 'UtilVcsFlash',
        priority = 100,
      })
    end
  end
  vim.defer_fn(function()
    if s.bufnr and api.nvim_buf_is_valid(s.bufnr) then pcall(api.nvim_buf_clear_namespace, s.bufnr, ns, 0, -1) end
  end, 300)
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

---Lock the repository across a whole action, including multi-file batches.
---The lock survives closing/reopening the panel while a command is running.
local function perform(s, label, run, after)
  if exec.busy[s.root] then
    vim.notify('VCS operation in progress: ' .. exec.busy[s.root], vim.log.levels.WARN)
    if after then after(false) end
    return
  end
  exec.busy[s.root] = label
  s.gen = s.gen + 1
  if state == s and s.last_status then render(s, s.last_status) end
  local finished = false
  local function done(res)
    if finished then return end
    finished = true
    exec.busy[s.root] = nil
    local ok = exec.report(res)
    if state and state.root == s.root then refresh(state) end
    if after then after(ok) end
  end
  local ok, err = pcall(run, done)
  if not ok then done({ code = -1, stderr = tostring(err) }) end
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

---Resolve the action targets: marked files when any, else the cursor row.
---Targets come from the last collected status (not the rendered rows), so
---marks inside folded sections still apply; the cursor row breaks ties.
---@param s table
---@return { file: VcsFile, section: VcsSection }[]
local function collect_targets(s)
  local targets, seen = {}, {}
  local any_marked = next(s.marks) ~= nil
  local status = s.last_status
  if status then
    for _, section in ipairs(status.sections) do
      for _, file in ipairs(section.files) do
        local key = target_key(file, section)
        if (not any_marked or s.marks[key]) and not seen[key] then
          targets[#targets + 1] = { file = file, section = section }
          seen[key] = true
        end
      end
    end
  end
  if not any_marked then
    -- no marks: fall back to the row under the cursor
    targets = {}
    local file, section = current_file(s)
    if file then targets[1] = { file = file, section = section } end
  end
  return targets
end

---Run `run_one(target, cb)` over `targets` sequentially (avoids git index
---lock contention). Failures are reported per file and never flashed; the
---successful rows flash and the panel refreshes once at the end.
---@param s table
---@param targets { file: VcsFile, section: VcsSection }[]
---@param run_one fun(target: table, cb: fun(res: vim.SystemCompleted))
local function run_batch(s, targets, run_one)
  perform(s, 'Updating files', function(done)
    local ok_paths, failed = {}, {}
    local i = 0
    local function step()
      i = i + 1
      local t = targets[i]
      if not t then
        if next(failed) ~= nil then
          local names = vim.tbl_keys(failed)
          table.sort(names)
          vim.notify(('Failed: %s'):format(table.concat(names, ', ')), vim.log.levels.ERROR, { title = 'VCS' })
        end
        if next(ok_paths) ~= nil then flash_rows(s, ok_paths) end
        done({ code = 0 })
        return
      end
      run_one(t, function(res)
        if res.code == 0 then
          ok_paths[t.file.path] = true
        else
          failed[t.file.path] = true
          exec.report(res)
        end
        step()
      end)
    end
    step()
  end)
end

---@param s table
---@param action 'stage'|'unstage'|'stage_all'
local function act_simple(s, action)
  local backend = s.backend
  if action == 'stage_all' then
    if not backend.stage_all then return not_supported(s) end
    perform(s, 'Stage all', function(done) backend.stage_all(s.root, done) end)
    return
  end

  if not backend[action] then return not_supported(s) end
  local row = s.rows[api.nvim_win_get_cursor(s.winnr)[1]]
  if row and row.hunk then
    if next(s.marks) then
      vim.notify('Clear file marks before acting on a hunk', vim.log.levels.WARN)
      return
    end
    if not backend.apply_hunk or row.file.code ~= 'M' or row.file.old_path or row.section.kind == 'conflicts' then
      vim.notify(
        'Hunk staging is available for modified Git files; use the file row for this change.',
        vim.log.levels.WARN
      )
      return
    end
    if (action == 'stage' and row.file.staged) or (action == 'unstage' and not row.file.staged) then return end
    perform(s, action .. ' hunk', function(done) backend.apply_hunk(s.root, row.file, row.raw, row.hunk, done) end)
    return
  end
  local targets = collect_targets(s)
  if #targets == 0 then return end

  -- validate sections: staging a staged row would pick up unrelated worktree
  -- changes; unstaging an unstaged row is a silent no-op
  local applicable = {}
  for _, t in ipairs(targets) do
    if action == 'stage' and t.section.kind ~= 'staged' then applicable[#applicable + 1] = t end
    if action == 'unstage' and t.section.kind == 'staged' then applicable[#applicable + 1] = t end
  end
  if #applicable == 0 then
    vim.notify(action == 'stage' and 'Already staged' or 'Not staged', vim.log.levels.INFO, { title = 'VCS' })
    return
  end

  run_batch(s, applicable, function(t, cb) backend[action](s.root, t.file.path, cb, t.file) end)
end

---@param s table
local function act_discard(s)
  local row = s.rows[api.nvim_win_get_cursor(s.winnr)[1]]
  if row and row.hunk then
    vim.notify('Select the file row to discard the file; hunk discard is not supported.', vim.log.levels.WARN)
    return
  end
  local targets = collect_targets(s)
  if #targets == 0 then return end
  if not s.backend.discard then return not_supported(s) end

  local names = {}
  for _, t in ipairs(targets) do
    names[#names + 1] = ('%s: %s%s'):format(
      t.section.title,
      t.file.path,
      t.file.staged and ' (index AND worktree)' or ''
    )
  end
  local what = table.concat(names, '\n')
  local choice = vim.fn.confirm(('Discard changes in %s?'):format(what), '&Yes\n&No', 2)
  if choice ~= 1 then return end

  run_batch(s, targets, function(t, cb) s.backend.discard(s.root, t.file, cb) end)
end

---@param s table
local function act_commit(s)
  if s.message_buf and api.nvim_buf_is_valid(s.message_buf) then
    if s.message_win and api.nvim_win_is_valid(s.message_win) then
      api.nvim_set_current_win(s.message_win)
    else
      s.message_win = require('util.win').open_bottom(s.message_buf, { height = 12 })
    end
    return
  end
  local function open(text, revision)
    if state ~= s then return end
    s.message_buf, s.message_win = require('util.vcs.message').open({
      root = s.backend.name .. ':' .. s.root,
      title = revision and ('Describe ' .. revision:sub(1, 12)) or 'Commit',
      text = text,
      submit = function(message, after)
        perform(s, 'Saving message', function(done) s.backend.commit(s.root, message, done, revision) end, after)
      end,
    })
  end
  if s.backend.name == 'jj' then
    exec.run(
      { 'jj', 'log', '--no-graph', '-r', '@', '-T', 'concat(change_id, "\n", description)' },
      s.root,
      function(res)
        if not exec.report(res) then return end
        local revision, description = (res.stdout or ''):match('^(%a+)\n(.*)$')
        if revision then open(description, revision) end
      end
    )
  else
    open('')
  end
end

-- ---------------------------------------------------------------------------
-- Marks & section folding

---Toggle selection marks: on a file row toggles that file; on a section row
---(or folded section) toggles all of its files.
---@param s table
local function act_toggle_mark(s)
  if not (s.winnr and api.nvim_win_is_valid(s.winnr)) then return end
  local row = s.rows and s.rows[api.nvim_win_get_cursor(s.winnr)[1]]
  if not row then return end
  if row.hunk then return end

  local function section_files(section)
    local all = {}
    for _, f in ipairs(section.files) do
      all[#all + 1] = target_key(f, section)
    end
    return all
  end

  if row.section and not row.file then
    local paths = section_files(row.section)
    local all_marked = true
    for _, p in ipairs(paths) do
      if not s.marks[p] then all_marked = false end
    end
    for _, p in ipairs(paths) do
      if all_marked then
        s.marks[p] = nil
      else
        s.marks[p] = true
      end
    end
  elseif row.file then
    local key = target_key(row.file, row.section)
    if s.marks[key] then
      s.marks[key] = nil
    else
      s.marks[key] = true
    end
    s.last_key = key
  else
    return
  end
  render(s, s.last_status)
end

---Toggle collapse of the section under the cursor.
---@param s table
local function act_toggle_fold(s)
  if not (s.winnr and api.nvim_win_is_valid(s.winnr)) then return end
  local row = s.rows and s.rows[api.nvim_win_get_cursor(s.winnr)[1]]
  if not (row and (row.section or row.kind == 'file')) then return end
  if row.file then
    local key = target_key(row.file, row.section)
    s.last_key = key
    if s.hunks[key] then
      s.hunks[key] = nil
      render(s, s.last_status)
      return
    end
    local cmd = s.backend.diff_cmd(s.root, row.file)
    if not cmd then return act_diff(s) end
    local gen = s.gen
    exec.run(cmd, s.root, function(res)
      if state ~= s or gen ~= s.gen or not exec.report(res) then return end
      local items = require('util.vcs.hunks').parse(res.stdout or '')
      if #items == 0 then
        vim.notify('No text hunks; use d to view the full diff.', vim.log.levels.INFO)
        return
      end
      s.hunks[key] = { items = items, raw = res.stdout }
      render(s, s.last_status)
    end)
    return
  end
  local section = row.section
  if not section and row.kind == 'file' then return end
  s.collapsed[section.kind] = not s.collapsed[section.kind] or nil
  render(s, s.last_status)
end

---Move to the next/previous section header.
---@param s table
---@param delta integer
local function act_goto_section(s, delta)
  if not (s.winnr and api.nvim_win_is_valid(s.winnr)) then return end
  local cur = api.nvim_win_get_cursor(s.winnr)[1]
  local rows = s.rows or {}
  local target
  if delta > 0 then
    for i = cur + 1, #rows do
      if rows[i].kind == 'section' then
        target = i
        break
      end
    end
  else
    for i = cur - 1, 1, -1 do
      if rows[i].kind == 'section' then
        target = i
        break
      end
    end
  end
  if target then pcall(api.nvim_win_set_cursor, s.winnr, { target, 0 }) end
end

local function backend_action(s, name)
  if not s.backend[name] then return not_supported(s) end
  perform(s, name, function(done) s.backend[name](s.root, done) end)
end

local function choose_revision(s, title, choose)
  exec.run(
    {
      'jj',
      'log',
      '--no-graph',
      '-r',
      'all()',
      '--limit',
      '300',
      '-T',
      'concat(change_id, " ", description.first_line(), "\n")',
    },
    s.root,
    function(res)
      if state ~= s or not exec.report(res) then return end
      local items = {}
      for line in vim.gsplit(res.stdout or '', '\n', { trimempty = true }) do
        local revision, description = line:match('^(%a+) (.*)$')
        if revision then
          items[#items + 1] = { text = revision:sub(1, 12) .. ' ' .. description, revision = revision }
        end
      end
      require('util.picker').open({
        title = title,
        items = items,
        on_choose = function(item)
          if state == s then choose(item.revision) end
        end,
      })
    end
  )
end

local ACTS = {
  open = act_open,
  diff = act_diff,
  stage = function(s) act_simple(s, 'stage') end,
  unstage = function(s) act_simple(s, 'unstage') end,
  stage_all = function(s) act_simple(s, 'stage_all') end,
  discard = act_discard,
  commit = act_commit,
  mark = act_toggle_mark,
  fold = act_toggle_fold,
  next_section = function(s) act_goto_section(s, 1) end,
  prev_section = function(s) act_goto_section(s, -1) end,
  push = function(s) backend_action(s, 'push') end,
  pull = function(s) backend_action(s, 'pull') end,
  new = function(s) backend_action(s, 'new_change') end,
  undo = function(s)
    if not s.backend.undo then return not_supported(s) end
    if vim.fn.confirm('Undo the last jj operation?', '&Undo\n&Cancel', 2) == 1 then backend_action(s, 'undo') end
  end,
  squash = function(s)
    if not s.backend.squash then return not_supported(s) end
    if vim.fn.confirm('Squash @ into its parent, keeping the parent description?', '&Squash\n&Cancel', 2) == 1 then
      backend_action(s, 'squash')
    end
  end,
  revision = function(s)
    if not s.backend.edit then return not_supported(s) end
    choose_revision(s, 'Edit jj revision', function(revision)
      perform(s, 'Edit revision', function(done) s.backend.edit(s.root, revision, done) end)
    end)
  end,
  bookmark = function(s)
    if not s.backend.bookmark then return not_supported(s) end
    choose_revision(s, 'Bookmark destination', function(revision)
      vim.ui.input({ prompt = 'Bookmark name: ' }, function(name)
        if state ~= s or not name or vim.trim(name) == '' then return end
        perform(s, 'Set bookmark', function(done) s.backend.bookmark(s.root, name, revision, done) end)
      end)
    end)
  end,
  errors = function(s)
    local lines = #exec.errors > 0 and vim.split(table.concat(exec.errors, '\n\n'), '\n')
      or { 'No VCS errors this session' }
    open_scratch_split(s, lines, 'text')
  end,
  log = function(s)
    if not s.backend.log then return not_supported(s) end
    s.backend.log(s.root, s.winnr, s.bufnr, function()
      if state == s then refresh(s) end
    end)
  end,
  refresh = function(s) refresh(s) end,
}

---Run a named action on the panel under the cursor (used by buffer keymaps).
---@param name string
function M._act(name)
  local s = state
  if not s then return end
  local mutating = {
    stage = true,
    unstage = true,
    stage_all = true,
    discard = true,
    commit = true,
    push = true,
    pull = true,
    new = true,
    squash = true,
    undo = true,
    bookmark = true,
    revision = true,
  }
  if mutating[name] and exec.busy[s.root] then
    vim.notify('VCS operation in progress: ' .. exec.busy[s.root], vim.log.levels.WARN)
    return
  end
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

  -- root from the backend's own marker so a forced `prefer` can never mix
  -- one repository's root with another backend's commands
  local root = require('util.repo').root(backend.marker)
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
    marks = {},
    hunks = {},
    collapsed = {},
    last_status = nil,
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
    signcolumn = 'auto:1',
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
  keymap('v', '<Cmd>lua require("util.vcs")._act("mark")<CR>')
  keymap('<Tab>', '<Cmd>lua require("util.vcs")._act("fold")<CR>')
  keymap(']]', '<Cmd>lua require("util.vcs")._act("next_section")<CR>')
  keymap('[[', '<Cmd>lua require("util.vcs")._act("prev_section")<CR>')
  keymap('p', '<Cmd>lua require("util.vcs")._act("pull")<CR>')
  keymap('P', '<Cmd>lua require("util.vcs")._act("push")<CR>')
  keymap('L', '<Cmd>lua require("util.vcs")._act("log")<CR>')
  keymap('R', '<Cmd>lua require("util.vcs")._act("refresh")<CR>')
  keymap('E', '<Cmd>lua require("util.vcs")._act("errors")<CR>')
  keymap('U', '<Cmd>lua require("util.vcs")._act("undo")<CR>')
  keymap('b', '<Cmd>lua require("util.vcs")._act("bookmark")<CR>')
  keymap('e', '<Cmd>lua require("util.vcs")._act("revision")<CR>')

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
      local file, section = current_file(s)
      if file then s.last_key = target_key(file, section) end
    end,
  })
  api.nvim_create_autocmd({ 'BufEnter', 'FocusGained' }, {
    group = group,
    buffer = s.bufnr,
    callback = function()
      if state ~= s then return end
      refresh(s)
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
