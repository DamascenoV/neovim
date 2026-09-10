local exec = require('util.vcs.exec')
local M = { name = 'jj' }

local RUN = 'jj'

---Header template: "jj · <change id> · (empty) · <description first line> · bookmarks"
local HEADER_TMPL =
  'concat("jj · ", change_id.short(8), if(empty, " · (empty)", ""), if(description.first_line(), " · " ++ description.first_line(), ""), if(bookmarks, " · " ++ bookmarks.join(", "), ""))'

local LOG_TMPL =
  'concat(commit_id, "\\t", if(current_working_copy, "1", "0"), "\\t", change_id.short(12), "  ", commit_id.short(8), if(current_working_copy, " @", ""), if(conflict, " conflict", ""), if(empty, " (empty)", ""), if(bookmarks, "  " ++ bookmarks.join(", "), ""), if(description.first_line(), "  " ++ description.first_line(), "  (no description)"), "  ", author.name(), "  ", author.timestamp().ago(), "\\n")'

---@return boolean
function M.available() return require('util.repo').root('.jj') ~= nil and vim.fn.executable(RUN) == 1 end

M.marker = '.jj'

M.help =
  '<CR> open · d diff · v mark · Tab expand/fold · - discard · c describe · n new · S squash · b bookmark · e edit revision · U undo · p fetch · P push · L log · E errors · R refresh · q close'

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
function M.commit(root, message, cb, revision)
  exec.run({ RUN, 'describe', '-r', revision or '@', '-m', message }, root, cb)
end

---Create a new empty change on top of `@`.
---@param root string
---@param cb fun(res: vim.SystemCompleted)
function M.new_change(root, cb) exec.run({ RUN, 'new' }, root, cb) end

---Squash `@` into its parent.
---@param root string
---@param cb fun(res: vim.SystemCompleted)
function M.squash(root, cb) exec.run({ RUN, 'squash', '--use-destination-message' }, root, cb) end

function M.undo(root, cb) exec.run({ RUN, 'undo' }, root, cb) end

function M.bookmark(root, name, revision, cb)
  exec.run({ RUN, 'bookmark', 'set', '--revision', revision, '--', name }, root, cb)
end

function M.edit(root, revision, cb) exec.run({ RUN, 'edit', '--', revision }, root, cb) end

---@param root string
---@param cb fun(res: vim.SystemCompleted)
function M.push(root, cb) exec.run({ RUN, 'git', 'push' }, root, cb) end

---@param root string
---@param cb fun(res: vim.SystemCompleted)
function M.pull(root, cb) exec.run({ RUN, 'git', 'fetch' }, root, cb) end

---Load graph rows without snapshotting the working copy. The full revision ID
---is parsed separately from its rendered graph row.
---@param root string
---@param revset string
---@param cb fun(res: vim.SystemCompleted, rows: table[]?)
function M.log_data(root, revset, cb)
  exec.run(
    {
      RUN,
      'log',
      '--at-operation',
      '@',
      '--ignore-working-copy',
      '-r',
      revset,
      '--limit',
      '300',
      '--color=never',
      '-T',
      LOG_TMPL,
    },
    root,
    function(res)
      if res.code ~= 0 then
        cb(res)
        return
      end
      local rows = {}
      for line in vim.gsplit(res.stdout or '', '\n', { trimempty = true }) do
        local graph, revision, working_copy, text = line:match('^(.-)([0-9a-f]+)\t([01])\t(.*)$')
        if revision then
          rows[#rows + 1] = {
            text = graph .. text,
            graph_end = #graph,
            revision = revision,
            working_copy = working_copy == '1',
          }
        else
          rows[#rows + 1] = { text = line }
        end
      end
      cb(res, rows)
    end
  )
end

---@param root string
---@param revision string
---@param cb fun(res: vim.SystemCompleted)
function M.show(root, revision, cb)
  exec.run({
    RUN,
    'show',
    '--at-operation',
    '@',
    '--ignore-working-copy',
    '--stat',
    '--color=never',
    '-r',
    revision,
  }, root, cb)
end

---Open the persistent interactive JJ revision graph.
---@param root string
---@param panel_win integer? panel window used to anchor the split
---@param panel_buf integer? panel buffer; inferred from panel_win when omitted
function M.log(root, panel_win, panel_buf)
  if not (panel_win and vim.api.nvim_win_is_valid(panel_win)) then return end
  panel_buf = panel_buf or vim.api.nvim_win_get_buf(panel_win)
  require('util.vcs.jj_log').open({
    root = root,
    panel_win = panel_win,
    panel_buf = panel_buf,
    backend = M,
  })
end

---@param root string
---@param file VcsFile
---@return string[]?
function M.diff_cmd(root, file)
  if file.untracked then return nil end
  local cmd = { RUN, 'diff', '--git', '--color=never', '--', file.path }
  -- renames/copies: include the old path so the diff covers both sides
  if file.old_path then cmd[#cmd + 1] = file.old_path end
  return cmd
end

return M
