local exec = require('util.vcs.exec')

local M = { name = 'jj' }

local RUN = 'jj'

---Header template: "jj · <change id> · (empty) · <description first line> · bookmarks"
local HEADER_TMPL =
  'concat("jj · ", change_id.short(8), if(empty, " · (empty)", ""), if(description.first_line(), " · " ++ description.first_line(), ""), if(bookmarks, " · " ++ bookmarks.join(", "), ""))'

---@return boolean
function M.available() return vim.fs.root('.', { '.jj' }) ~= nil end

M.help =
  '<CR> open · d diff · - discard · c describe · n new · S squash · p fetch · P push · L log · R refresh · q close'

---Parse `jj diff --summary` output (codes MADRCC? per line).
---Renames/copies use jj brace groups: `R dir/{old => new}/rest`.
---@param out string
---@return VcsFile[]
local function parse_summary(out)
  local files = {}
  for _, line in ipairs(vim.split(out, '\n', { trimempty = true })) do
    local code, rest = line:match('^([MADRCC?]) (.+)$')
    if code and rest then
      local file = { path = rest, code = code, copy = code == 'C' or nil }
      if code == 'R' or code == 'C' then
        local prefix, old_part, new_part, suffix = rest:match('^(.-){(.-) => (.-)}(.*)$')
        if prefix then
          local function join(part)
            local path = (prefix .. part .. suffix):gsub('//', '/'):gsub('^/', '')
            return path
          end
          file.old_path = join(old_part)
          file.path = join(new_part)
          file.display = ('%s <- %s'):format(file.path, file.old_path)
        else
          -- simple form: "old => new"
          local old_path, new_path = rest:match('^(.+)%s+=>%s+(.+)$')
          if old_path then
            file.old_path = vim.trim(old_path)
            file.path = vim.trim(new_path)
            file.display = ('%s <- %s'):format(file.path, file.old_path)
          end
        end
      end
      files[#files + 1] = file
    end
  end
  return files
end

---@param root string repository root (command cwd)
---@param cb fun(status: VcsStatus?)
function M.collect(root, cb)
  exec.run({ RUN, 'log', '--no-graph', '-r', '@', '--template', HEADER_TMPL }, root, function(header_res)
    exec.run({ RUN, 'diff', '--summary' }, root, function(summary)
      -- resolve --list fails when there are no conflicts; only a zero exit
      -- carries conflict paths
      exec.run({ RUN, 'resolve', '--list' }, root, function(conflicts)
        if summary.code ~= 0 then
          exec.report(summary)
          cb(nil)
          return
        end

        local header = header_res.code == 0 and vim.trim(header_res.stdout or '') or 'jj'
        local files = parse_summary(summary.stdout or '')

        -- each line is "<path>␠␠<N>-sided conflict"; the path ends at the
        -- first run of 2+ spaces
        local conflicted = {}
        if conflicts.code == 0 then
          for _, line in ipairs(vim.split(conflicts.stdout or '', '\n', { trimempty = true })) do
            local path = line:match('^(.-)%s%s') or line
            path = vim.trim(path)
            if path ~= '' then conflicted[#conflicted + 1] = { path = path, code = 'C' } end
          end
        end

        local sections = {}
        if #files > 0 then sections[#sections + 1] = { kind = 'working', title = 'Working copy', files = files } end
        if #conflicted > 0 then
          sections[#sections + 1] = { kind = 'conflicts', title = 'Conflicts', files = conflicted }
        end

        cb({ header = header, sections = sections })
      end)
    end)
  end)
end

---Discard local changes to `file` by restoring it from the parent revision.
---Renames restore both the old and new paths.
---@param root string
---@param file VcsFile
---@param cb fun(res: vim.SystemCompleted)
function M.discard(root, file, cb)
  local cmd = { RUN, 'restore', '--' }
  if file.old_path and not file.copy then cmd[#cmd + 1] = file.old_path end
  cmd[#cmd + 1] = file.path
  exec.run(cmd, root, cb)
end

---Describe the working-copy commit (`@`).
---@param root string
---@param cb fun(res: vim.SystemCompleted)
function M.commit(root, cb)
  vim.ui.input({ prompt = 'Change description: ' }, function(msg)
    if not msg or msg == '' then return end
    exec.run({ RUN, 'describe', '-m', msg }, root, cb)
  end)
end

---Create a new empty change on top of `@`.
---@param root string
---@param cb fun(res: vim.SystemCompleted)
function M.new_change(root, cb) exec.run({ RUN, 'new' }, root, cb) end

---Squash `@` into its parent.
---@param root string
---@param cb fun(res: vim.SystemCompleted)
function M.squash(root, cb) exec.run({ RUN, 'squash' }, root, cb) end

---@param root string
---@param cb fun(res: vim.SystemCompleted)
function M.push(root, cb) exec.run({ RUN, 'git', 'push' }, root, cb) end

---@param root string
---@param cb fun(res: vim.SystemCompleted)
function M.pull(root, cb) exec.run({ RUN, 'git', 'fetch' }, root, cb) end

---Create a nofile scratch buffer holding `lines`.
---@param lines string[]
---@return integer bufnr
local function open_scratch(lines)
  local buf = vim.api.nvim_create_buf(false, true)
  pcall(vim.api.nvim_set_option_value, 'bufhidden', 'wipe', { buf = buf })
  pcall(vim.api.nvim_set_option_value, 'buftype', 'nofile', { buf = buf })
  pcall(vim.api.nvim_set_option_value, 'swapfile', false, { buf = buf })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  pcall(vim.api.nvim_set_option_value, 'filetype', 'jj', { buf = buf })
  return buf
end

---Open the jj log in a scratch split anchored to `panel_win`.
---@param root string
---@param panel_win integer? panel window used to anchor the split
function M.log(root, panel_win)
  exec.run({ RUN, 'log', '--limit', '50' }, root, function(res)
    local ok = exec.report(res)
    if not ok then return end
    vim.schedule(function()
      local lines = vim.split(res.stdout or '', '\n', { trimempty = true })
      local buf = open_scratch(lines)
      if panel_win and vim.api.nvim_win_is_valid(panel_win) then
        vim.api.nvim_open_win(buf, true, { split = 'below', win = panel_win, height = math.floor(vim.o.lines / 2) })
      else
        vim.cmd('split')
        vim.api.nvim_win_set_buf(0, buf)
      end
    end)
  end)
end

---@param root string
---@param file VcsFile
---@return string[]?
function M.diff_cmd(root, file)
  if file.untracked then return nil end
  local cmd = { RUN, 'diff', '--git', '--', file.path }
  -- renames/copies: include the old path so the diff covers both sides
  if file.old_path then cmd[#cmd + 1] = file.old_path end
  return cmd
end

return M
