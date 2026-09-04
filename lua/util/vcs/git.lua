local exec = require('util.vcs.exec')

local M = { name = 'git' }

local RUN = 'git'

---@return boolean
function M.available() return vim.fs.root('.', { '.git' }) ~= nil end

M.help =
  '<CR> open · d diff · s stage · u unstage · a stage all · - discard · c commit · p pull · P push · L log · R refresh · q close'

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

    if x:match('[RC]') or y:match('[RC]') then
      local nul2 = out:find('\0', pos, true)
      if nul2 then
        display = ('%s <- %s'):format(path, out:sub(pos, nul2 - 1))
        pos = nul2 + 1
      end
    end

    -- xy holds both status bytes plus the separator, so compare via x/y
    if x == '?' then
      untracked[#untracked + 1] = { path = path, display = display, code = '??', untracked = true }
    elseif x == 'U' or y == 'U' or (x == 'A' and y == 'A') or (x == 'D' and y == 'D') then
      conflicts[#conflicts + 1] = { path = path, display = display, code = x ~= ' ' and x or y }
    else
      if x ~= ' ' then staged[#staged + 1] = { path = path, display = display, code = x, staged = true } end
      if y ~= ' ' then unstaged[#unstaged + 1] = { path = path, display = display, code = y } end
    end
  end
  return staged, unstaged, untracked, conflicts
end

---@param root string repository root (command cwd)
---@param cb fun(status: VcsStatus?)
function M.collect(root, cb)
  exec.run({ RUN, 'branch', '--show-current' }, root, function(branch)
    exec.run({ RUN, 'log', '-1', '--no-color', '--pretty=format:%h %s' }, root, function(log)
      exec.run({ RUN, 'status', '--porcelain=v1', '-z' }, root, function(res)
        if res.code ~= 0 then
          exec.report(res)
          cb(nil)
          return
        end

        local staged, unstaged, untracked, conflicts = parse_status(res.stdout or '')
        local head = vim.trim(log.stdout or '')
        local b = vim.trim(branch.stdout or '')
        local header
        if head == '' then
          header = ('git · %s · no commits yet'):format(b ~= '' and b or '(no branch)')
        else
          header = ('git · %s · %s'):format(b ~= '' and b or '(no branch)', head)
        end

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

---Unstage one file. Falls back to `git rm --cached` when HEAD is unborn
---(restore --staged needs a HEAD to diff the index against).
---@param root string
---@param path string
---@param cb fun(res: vim.SystemCompleted)
function M.unstage(root, path, cb)
  exec.run({ RUN, 'restore', '--staged', '--', path }, root, function(res)
    if res.code == 0 then
      cb(res)
      return
    end
    exec.run({ RUN, 'rm', '--cached', '--', path }, root, cb)
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
    cmd = { RUN, 'clean', '-f', '--', file.path }
  elseif file.staged then
    cmd = { RUN, 'restore', '--staged', '--worktree', '--', file.path }
  else
    cmd = { RUN, 'restore', '--', file.path }
  end
  exec.run(cmd, root, cb)
end

---Commit the staged changes with a prompted message.
---@param root string
---@param cb fun(res: vim.SystemCompleted)
function M.commit(root, cb)
  vim.ui.input({ prompt = 'Commit message: ' }, function(msg)
    if not msg or msg == '' then return end
    exec.run({ RUN, 'commit', '-m', msg }, root, cb)
  end)
end

---@param root string
---@param cb fun(res: vim.SystemCompleted)
function M.push(root, cb) exec.run({ RUN, 'push' }, root, cb) end

---@param root string
---@param cb fun(res: vim.SystemCompleted)
function M.pull(root, cb) exec.run({ RUN, 'pull' }, root, cb) end

---Open the existing git commits picker source.
function M.log(_root) require('util.picker_sources').get('git_commits').start({}) end

---@param root string
---@param file VcsFile
---@return string[]?
function M.diff_cmd(root, file)
  if file.untracked then return nil end
  if file.staged then return { RUN, 'diff', '--cached', '--no-color', '--', file.path } end
  return { RUN, 'diff', '--no-color', '--', file.path }
end

return M
