local exec = require('util.vcs.exec')

local M = { name = 'git' }

local RUN = 'git'

---@return boolean
function M.available() return require('util.repo').root('.git') ~= nil and vim.fn.executable(RUN) == 1 end

M.marker = '.git'

M.help =
  '<CR> open · d diff · v mark · Tab expand/fold · s stage · u unstage · a all · - discard · c commit · p pull · P push · L log · E errors · ]] section · R refresh · q close'

---Parse `git status --porcelain=v1 -z` into section file lists.
---Records are NUL-delimited so paths need no unquoting; renames carry a
---second pathname record (the original path).
---@param out string
---@return VcsFile[] staged, VcsFile[] unstaged, VcsFile[] untracked, VcsFile[] conflicts
local function parse_status(out)
  local staged, unstaged, untracked, conflicts = {}, {}, {}, {}
  local pos = 1
  while pos <= #out do
    local xy = out:sub(pos, pos + 2)
    pos = pos + 3
    local nul = out:find('\0', pos, true)
    if not nul then break end
    local path = out:sub(pos, nul - 1)
    pos = nul + 1
    local x, y = xy:sub(1, 1), xy:sub(2, 2)
    local display = path
    local old_path

    if x:match('[RC]') or y:match('[RC]') then
      local nul2 = out:find('\0', pos, true)
      if nul2 then
        old_path = out:sub(pos, nul2 - 1)
        display = ('%s <- %s'):format(path, old_path)
        pos = nul2 + 1
      end
    end

    -- xy holds both status bytes plus the separator, so compare via x/y
    if x == '?' then
      untracked[#untracked + 1] = { path = path, display = display, code = '??', untracked = true }
    elseif x == 'U' or y == 'U' or (x == 'A' and y == 'A') or (x == 'D' and y == 'D') then
      conflicts[#conflicts + 1] = { path = path, display = display, code = x ~= ' ' and x or y }
    else
      if x ~= ' ' then
        staged[#staged + 1] =
          { path = path, display = display, code = x, staged = true, old_path = old_path, copy = x == 'C' }
      end
      if y ~= ' ' then unstaged[#unstaged + 1] = { path = path, display = display, code = y } end
    end
  end
  return staged, unstaged, untracked, conflicts
end

---Append upstream tracking info ("↑1↓2") parsed from `git status -sb`.
---@param line string first line of `git status -sb`
---@return string suffix ('' when there is no upstream)
local function tracking_suffix(line)
  local bracket = line:match('%[([^%]]*)%]')
  if not bracket then return '' end
  local ahead = bracket:match('ahead (%d+)')
  local behind = bracket:match('behind (%d+)')
  local parts = {}
  if ahead then parts[#parts + 1] = ('↑%s'):format(ahead) end
  if behind then parts[#parts + 1] = ('↓%s'):format(behind) end
  if #parts == 0 then return '' end
  return (' · %s'):format(table.concat(parts, ''))
end

---@param root string repository root (command cwd)
---@param cb fun(status: VcsStatus?)
function M.collect(root, cb)
  exec.run({ RUN, 'log', '-1', '--no-color', '--pretty=format:%h %s' }, root, function(log)
    exec.run({ RUN, 'status', '--porcelain=v1', '-z', '--branch' }, root, function(res)
      if res.code ~= 0 then
        exec.report(res)
        cb(nil)
        return
      end

      local out = res.stdout or ''
      -- with -z every record is NUL-terminated, including the branch line
      local sb = out:match('^(.-)%z') or out
      local branch_line = sb:gsub('^## ', '')
      -- upstream form: "<branch>...<upstream>"; non-greedy so branch names
      -- with dots keep their trailing characters
      local b, upstream = branch_line:match('^(.-)%.%.%.(.*)$')
      if not b then
        b = vim.trim(branch_line)
        upstream = ''
      end
      local unborn = b:match('^No commits yet on (.+)$')
      if unborn then b = unborn end

      local head = vim.trim(log.stdout or '')
      local header
      if head == '' then
        header = ('git · %s · no commits yet'):format(b ~= '' and b or '(no branch)')
      else
        header = ('git · %s · %s%s'):format(b ~= '' and b or '(no branch)', head, tracking_suffix(upstream))
      end

      -- status records follow the branch line's NUL terminator
      local status_body = #sb < #out and out:sub(#sb + 2) or ''
      local staged, unstaged, untracked, conflicts = parse_status(status_body)

      local sections = {}
      local function add(kind, title, files)
        if #files == 0 then return end
        sections[#sections + 1] = { kind = kind, title = title, files = files }
      end
      add('staged', 'Staged', staged)
      add('unstaged', 'Unstaged', unstaged)
      add('conflicts', 'Conflicts', conflicts)
      add('untracked', 'Untracked', untracked)

      cb({ header = header, sections = sections })
    end)
  end)
end

---Stage one file. Only meaningful for rows outside the staged section.
---@param root string
---@param path string
---@param cb fun(res: vim.SystemCompleted)
function M.stage(root, path, cb) exec.run({ RUN, 'add', '--', path }, root, cb) end

---@param root string
---@param cb fun(res: vim.SystemCompleted)
function M.stage_all(root, cb) exec.run({ RUN, 'add', '-A' }, root, cb) end

---Unstage one file. Falls back to `git rm --cached` only when HEAD is unborn
---(restore --staged needs a HEAD to diff the index against).
---@param root string
---@param path string
---@param cb fun(res: vim.SystemCompleted)
function M.unstage(root, path, cb, file)
  local cmd = { RUN, 'restore', '--staged', '--', path }
  if file and file.old_path and not file.copy then cmd[#cmd + 1] = file.old_path end
  exec.run(cmd, root, function(res)
    if res.code == 0 then
      cb(res)
      return
    end
    exec.run({ RUN, 'rev-parse', '--verify', '-q', 'HEAD' }, root, function(head)
      if head.code == 0 then
        cb(res) -- real failure (index lock, permissions, ...)
        return
      end
      exec.run({ RUN, 'rm', '--cached', '--', path }, root, cb)
    end)
  end)
end

---Discard changes to one file. Staged rows discard both the index and the
---worktree copy; untracked files are cleaned.
---@param root string
---@param file VcsFile
---@param cb fun(res: vim.SystemCompleted)
function M.discard(root, file, cb)
  local cmd
  if file.untracked then
    cmd = { RUN, 'clean', '-fd', '--', file.path }
  elseif file.staged then
    cmd = { RUN, 'restore', '--staged', '--worktree', '--', file.path }
    if file.old_path and not file.copy then cmd[#cmd + 1] = file.old_path end
  else
    cmd = { RUN, 'restore', '--', file.path }
  end
  exec.run(cmd, root, cb)
end

---Commit the staged changes with a prompted message.
---@param root string
---@param cb fun(res: vim.SystemCompleted)
function M.commit(root, message, cb) exec.run({ RUN, 'commit', '-F', '-' }, root, cb, { stdin = message }) end

---@param root string
---@param cb fun(res: vim.SystemCompleted)
function M.push(root, cb) exec.run({ RUN, 'push' }, root, cb) end

---@param root string
---@param cb fun(res: vim.SystemCompleted)
function M.pull(root, cb) exec.run({ RUN, 'pull' }, root, cb) end

---Open the existing git commits picker source, bound to the repo root.
---@param root string
function M.log(root) require('util.picker_sources').get('git_commits').start({ cwd = root }) end

---@param root string
---@param file VcsFile
---@return string[]?
function M.diff_cmd(root, file)
  if file.untracked then return nil end
  local cmd = { RUN, 'diff', '--no-color', '--no-ext-diff', '--no-textconv', '--src-prefix=a/', '--dst-prefix=b/' }
  if file.staged then cmd[#cmd + 1] = '--cached' end
  vim.list_extend(cmd, { '--', file.path })
  if file.old_path then cmd[#cmd + 1] = file.old_path end
  return cmd
end

function M.apply_hunk(root, file, raw, hunk, cb)
  if raw:find('\nold mode ', 1, true) or raw:find('\nnew mode ', 1, true) then
    cb({ code = 1, stderr = 'Use the file row to stage a permission change together with its content.' })
    return
  end
  -- A displayed hunk is only valid for the snapshot from which it was built.
  exec.run(M.diff_cmd(root, file), root, function(res)
    if res.code ~= 0 then
      cb(res)
      return
    end
    if res.stdout ~= raw then
      cb({ code = 1, stderr = 'Diff changed; refresh and select the hunk again.' })
      return
    end
    local cmd = { RUN, 'apply', '--cached', '--whitespace=nowarn' }
    if file.staged then cmd[#cmd + 1] = '--reverse' end
    exec.run(cmd, root, cb, { stdin = hunk.patch })
  end)
end

return M
