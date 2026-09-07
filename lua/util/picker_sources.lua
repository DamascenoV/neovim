local api = vim.api
local ansi = require('util.ansi')
local picker = require('util.picker')
local repo = require('util.repo')
local rg = require('util.rg')

local M = {}

local function notify(msg, level) vim.notify(msg, level or vim.log.levels.INFO, { title = 'Pick' }) end

local function path_items(paths)
  local items = {}
  local seen = {}
  for _, path in ipairs(paths) do
    if path ~= '' and not seen[path] then
      seen[path] = true
      items[#items + 1] = { text = path, path = path }
    end
  end
  return items
end

local function open_path(path, lnum, col)
  local winnr = api.nvim_get_current_win()
  local ok = pcall(vim.cmd.edit, vim.fn.fnameescape(path))
  if not ok then
    notify(('Unable to open %s'):format(path), vim.log.levels.WARN)
    return
  end
  if lnum then pcall(api.nvim_win_set_cursor, winnr, { lnum, (col or 1) - 1 }) end
end

local function jump_on_choose(item)
  local col = item.col
  -- LSP-style character columns need byte conversion for correct jumps
  if col and item.char_col and item.path and item.lnum then
    col = picker.char_col_to_byte(item.path, item.lnum, col, item.char_encoding)
  end
  open_path(item.path, item.lnum, col)
end

local function set_cmdline(prefix, text)
  text = (text or ''):gsub('%c', '')
  local ok, ret = pcall(vim.fn.setcmdline, prefix .. text)
  if ok and ret == 0 then return end
  -- Fallback: type the keys literally (control chars already stripped)
  api.nvim_feedkeys(prefix .. text, 'n', false)
end

local function git_lines(args, title, cwd)
  if vim.fn.executable('git') ~= 1 then
    notify('git is not installed', vim.log.levels.ERROR)
    return nil
  end
  local ok, res = pcall(function() return vim.system(args, { text = true, cwd = cwd }):wait() end)
  if not ok or not res then return nil end
  if res.code ~= 0 then
    notify(('%s failed: %s'):format(title, vim.trim(res.stderr or ''):sub(1, 200)), vim.log.levels.ERROR)
    return nil
  end
  return vim.split(res.stdout or '', '\n', { trimempty = true })
end

--- Like `git_lines` but returns the raw stdout (used with --color=always so the
--- ansi module can turn git's own palette into highlight spans).
---@param args string[]
---@param title string
---@param cwd string?
---@return string? stdout
local function git_raw(args, title, cwd)
  if vim.fn.executable('git') ~= 1 then
    notify('git is not installed', vim.log.levels.ERROR)
    return nil
  end
  local ok, res = pcall(function() return vim.system(args, { text = true, cwd = cwd }):wait() end)
  if not ok or not res then return nil end
  if res.code ~= 0 then
    notify(('%s failed: %s'):format(title, vim.trim(res.stderr or ''):sub(1, 200)), vim.log.levels.ERROR)
    return nil
  end
  return res.stdout or ''
end

local sources = {}

local function file_source(opts, ignored)
  local cwd = repo.project(opts.cwd)
  local cancel
  local ctx = picker.open({
    title = ignored and 'Hidden & ignored files' or 'Files',
    query = opts.query,
    on_choose = jump_on_choose,
    on_teardown = function()
      if cancel then cancel() end
    end,
  })
  ctx.set_status('loading…')
  cancel = rg.start('files', { cwd = cwd, ignored = ignored }, function(items, result)
    if not ctx.is_active() then return end
    if result.code > 1 or result.code < 0 then notify(result.error, vim.log.levels.ERROR) end
    ctx.set_status(result.truncated and 'limit reached' or '')
    ctx.set_items(items)
  end)
  return ctx
end

sources.files = {
  title = 'Files',
  start = function(opts) return file_source(opts, false) end,
}

sources.hidden = {
  title = 'Hidden & ignored files',
  start = function(opts) return file_source(opts, true) end,
}

sources.buffers = {
  title = 'Buffers',
  start = function(opts)
    local function build_items()
      local items = {}
      for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        local name = b.name ~= '' and b.name or '[No Name]'
        items[#items + 1] = {
          text = ('%d %s%s'):format(b.bufnr, name, b.changed == 1 and ' [+]' or ''),
          bufnr = b.bufnr,
          path = b.name ~= '' and b.name or nil,
        }
      end
      return items
    end

    local ctx
    ctx = picker.open({
      title = 'Buffers',
      query = opts.query,
      delete_action = function(item)
        local ok, err = pcall(api.nvim_buf_delete, item.bufnr, { force = false })
        if not ok then
          notify(('Unable to delete buffer %d (unsaved changes?): %s'):format(item.bufnr, err), vim.log.levels.WARN)
          return
        end
        if ctx.is_active() then ctx.set_items(build_items()) end
      end,
      on_choose = function(item)
        if not api.nvim_buf_is_valid(item.bufnr) then
          notify('Buffer no longer exists', vim.log.levels.WARN)
          return
        end
        api.nvim_win_set_buf(0, item.bufnr)
      end,
    })
    ctx.set_items(build_items())
    return ctx
  end,
}

sources.oldfiles = {
  title = 'Recent files',
  start = function(opts)
    local ctx = picker.open({
      title = 'Recent files',
      query = opts.query,
      on_choose = jump_on_choose,
    })
    ctx.set_items(path_items(vim.v.oldfiles or {}))
    return ctx
  end,
}

sources.commands = {
  title = 'Commands',
  start = function(opts)
    local ctx = picker.open({
      title = 'Commands',
      query = opts.query,
      on_choose = function(item) set_cmdline(':', item .. ' ') end,
    })
    ctx.set_items(vim.fn.getcompletion('', 'command'))
    return ctx
  end,
}

sources.buf_lines = {
  title = 'Lines in buffer',
  start = function(opts)
    local bufnr = api.nvim_get_current_buf()
    local bufname = api.nvim_buf_get_name(bufnr)
    local items = {}
    for i, line in ipairs(api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
      if line ~= '' then
        items[#items + 1] = { text = ('%5d %s'):format(i, line), path = bufname ~= '' and bufname or nil, lnum = i }
      end
    end

    local ctx = picker.open({
      title = 'Lines in buffer',
      query = opts.query,
      on_choose = function(item) pcall(api.nvim_win_set_cursor, 0, { item.lnum, 0 }) end,
    })
    ctx.set_items(items)
    return ctx
  end,
}

sources.grep = {
  title = 'Live grep',
  start = function(opts)
    local cwd = repo.project(opts.cwd)
    local req_id = 0
    local active_job
    local function stop_job()
      if active_job then
        active_job()
        active_job = nil
      end
    end

    local ctx = picker.open({
      title = 'Live grep',
      query = opts.query,
      filter = false, -- ripgrep does the matching; local filtering would hide regex matches
      on_choose = jump_on_choose,
      on_teardown = stop_job, -- stop a still-running rg on choose or dismiss
    })

    local function run(query)
      if not ctx.is_active() then return end
      req_id = req_id + 1
      local id = req_id

      -- A superseded rg process is still running: stop it before starting anew
      stop_job()

      if vim.trim(query) == '' then
        ctx.set_status('')
        ctx.set_items({})
        return
      end
      if vim.fn.executable('rg') ~= 1 then
        notify('ripgrep (rg) is not installed', vim.log.levels.ERROR)
        ctx.set_items({})
        return
      end

      ctx.set_status('searching…')
      ctx.set_items({})
      active_job = rg.start('grep', { cwd = cwd, query = query }, function(items, result)
        if not ctx.is_active() or id ~= req_id or query ~= ctx.get_query() then return end
        if result.code > 1 or result.code < 0 then
          notify(vim.trim(result.error or 'rg failed'), vim.log.levels.ERROR)
          ctx.set_status('search failed')
          ctx.set_items({})
          return
        end
        ctx.set_status(result.truncated and 'limit reached' or '')
        ctx.set_items(items)
      end)
    end

    ctx.watch(run)
    run(ctx.get_query())
    return ctx
  end,
}

sources.diagnostic = {
  title = 'Diagnostics',
  start = function(opts)
    local all_buffers = opts.query == 'all'
    local diags = all_buffers and vim.diagnostic.get() or vim.diagnostic.get(0)

    local items = {}
    for _, diag in ipairs(diags) do
      local path = vim.api.nvim_buf_get_name(diag.bufnr)
      local severity = vim.diagnostic.severity[diag.severity] or 'UNKNOWN'
      local label = path ~= '' and path or ('[buf %d]'):format(diag.bufnr)
      items[#items + 1] = {
        text = ('%s:%d [%s] %s'):format(label, diag.lnum + 1, severity, diag.message:gsub('[\r\n]+', ' ')),
        bufnr = diag.bufnr,
        path = path ~= '' and path or nil,
        lnum = diag.lnum + 1,
        col = (diag.col or 0) + 1,
      }
    end

    if #items == 0 then
      notify(all_buffers and 'No diagnostics in the workspace' or 'No diagnostics in this buffer')
      return
    end

    local ctx = picker.open({
      title = all_buffers and 'Diagnostics (all buffers)' or 'Diagnostics (buffer)',
      on_choose = function(item)
        if item.bufnr and api.nvim_buf_is_valid(item.bufnr) then pcall(api.nvim_win_set_buf, 0, item.bufnr) end
        pcall(api.nvim_win_set_cursor, 0, { item.lnum, (item.col or 1) - 1 })
      end,
    })
    ctx.set_items(items)
    return ctx
  end,
}

sources.lsp = {
  title = 'LSP',
  start = function(opts)
    local kind = opts.query or 'references'
    local method = kind == 'implementation' and 'textDocument/implementation' or 'textDocument/references'
    local source_win = api.nvim_get_current_win()
    -- Per-client params: each server gets positions in its own offset encoding
    local params_fn = function(client)
      if not api.nvim_win_is_valid(source_win) then return nil end
      local ok, params = pcall(vim.lsp.util.make_position_params, source_win, client.offset_encoding)
      if not ok or not params then return nil end
      if method == 'textDocument/references' then params.context = { includeDeclaration = false } end
      return params
    end

    local ok, results = pcall(vim.lsp.buf_request_sync, 0, method, params_fn, 3000)
    if not ok then
      notify('LSP request failed', vim.log.levels.WARN)
      return
    end

    local items = {}
    for client_id, client_result in pairs(results or {}) do
      -- The response's `character` fields use the answering client's encoding
      local client = vim.lsp.get_client_by_id(client_id)
      local enc = client and client.offset_encoding or 'utf-16'
      local locations = client_result.result
      if type(locations) == 'table' then
        if locations.uri or locations.targetUri then locations = { locations } end
        for _, loc in ipairs(locations) do
          local path = vim.uri_to_fname(loc.uri or loc.targetUri)
          local range = loc.range or loc.targetSelectionRange or { start = { line = 0, character = 0 } }
          items[#items + 1] = {
            text = ('%s:%d'):format(path, range.start.line + 1),
            path = path,
            lnum = range.start.line + 1,
            col = range.start.character + 1, -- 1-based char col; converted to bytes on jump
            char_col = true,
            char_encoding = enc,
          }
        end
      end
    end

    if #items == 0 then
      notify(('No LSP %s found'):format(kind))
      return
    end

    local ctx = picker.open({
      title = ('LSP %s (%d)'):format(kind, #items),
      on_choose = jump_on_choose,
    })
    ctx.set_items(items)
    return ctx
  end,
}

sources.git_commits = {
  title = 'Git commits',
  start = function(opts)
    local cwd = repo.root('.git', opts.cwd)
    if not cwd then return notify('Not inside a Git repository', vim.log.levels.WARN) end
    -- --color=always so git's native palette becomes highlight spans (see util.ansi)
    local raw = git_raw({
      'git',
      'log',
      '-n',
      '300',
      '--color=always',
      '--date=short',
      '--pretty=format:%C(yellow)%h%C(reset) %C(blue)%an%C(reset) %C(dim white)%ad%C(reset) %s',
    }, 'git log', cwd)
    if not raw or raw == '' then
      notify('No commits found')
      return
    end

    local lines, spans = ansi.parse(raw)
    local items = {}
    for i, line in ipairs(lines) do
      local sha = line:match('^(%x+)')
      if sha then items[#items + 1] = { text = line, sha = sha, hl = spans[i] } end
    end

    local ctx = picker.open({
      title = 'Git commits',
      query = opts.query,
      items = items,
      on_choose = function(item)
        local show = git_lines({ 'git', 'show', '--no-color', '--patch', item.sha }, 'git show', cwd)
        if not show then return end

        local bufnr = api.nvim_create_buf(false, true)
        pcall(api.nvim_buf_set_name, bufnr, ('git show %s'):format(item.sha:sub(1, 12)))
        api.nvim_buf_set_lines(bufnr, 0, -1, false, show)
        api.nvim_set_option_value('buftype', 'nofile', { buf = bufnr })
        api.nvim_set_option_value('bufhidden', 'wipe', { buf = bufnr })
        vim.cmd('vsplit')
        api.nvim_win_set_buf(0, bufnr)
        pcall(api.nvim_set_option_value, 'filetype', 'git', { buf = bufnr })
      end,
    })
    return ctx
  end,
}

sources.git_hunks = {
  title = 'Git hunks',
  start = function(opts)
    local cwd = repo.root('.git', opts.cwd)
    if not cwd then return notify('Not inside a Git repository', vim.log.levels.WARN) end
    local lines = git_lines(
      { 'git', '-c', 'core.quotePath=false', 'diff', 'HEAD', '--no-color', '-U0', '--no-renames' },
      'git diff',
      cwd
    )
    if not lines or #lines == 0 then
      notify('No uncommitted changes')
      return
    end

    local items = {}
    local file
    for _, line in ipairs(lines) do
      if line:match('^%+%+%+%s*/dev/null') then
        file = nil -- deleted file: no new-side hunks to jump to
      else
        local plus = line:match('^%+%+%+%s*b/(.*)$')
        if plus then
          file = plus
        else
          -- "@@ -a,b +c,d @@ context"; c is the 1-based new-side start (c == 0
          -- only for hunks attached to an empty new file, nothing to jump to)
          local lnum, header = line:match('^@@ %-%d+,?%d* %+(%d+),?%d* @@%s?(.*)$')
          if file and lnum then
            lnum = tonumber(lnum)
            if lnum > 0 then
              items[#items + 1] =
                { text = ('%s:%d %s'):format(file, lnum, header or ''), path = vim.fs.joinpath(cwd, file), lnum = lnum }
            end
          end
        end
      end
    end

    if #items == 0 then
      notify('No hunks found')
      return
    end

    local ctx = picker.open({
      title = 'Git hunks',
      query = opts.query,
      on_choose = jump_on_choose,
    })
    ctx.set_items(items)
    return ctx
  end,
}

sources.git_status = {
  title = 'Git status',
  start = function(opts)
    local cwd = repo.root('.git', opts.cwd)
    if not cwd then return notify('Not inside a Git repository', vim.log.levels.WARN) end
    -- -z: NUL-delimited records, no quoting/escaping of paths.
    -- vim.system preserves NUL bytes; vim.fn.system would replace them with \x01.
    local ok, res = pcall(
      function() return vim.system({ 'git', 'status', '--porcelain=v1', '-z' }, { text = true, cwd = cwd }):wait() end
    )
    if not ok or res.code ~= 0 then
      notify(
        ('git status failed: %s'):format(ok and res and vim.trim(res.stderr or '') or tostring(res)),
        vim.log.levels.ERROR
      )
      return
    end
    local out = res.stdout or ''
    if vim.trim((out:gsub('%z', '\n'))) == '' then
      notify('Git working tree is clean')
      return
    end
    local items = {}
    local pos = 1
    while pos <= #out do
      local xy = out:sub(pos, pos + 2) -- "XY " (X=staged, Y=unstaged)
      pos = pos + 3
      local nul = out:find('\0', pos, true)
      if not nul then break end
      local path = out:sub(pos, nul - 1)
      pos = nul + 1

      if xy:sub(1, 1):match('[RC]') or xy:sub(2, 2):match('[RC]') then
        -- rename/copy in either status column: a second pathname record follows
        local nul2 = out:find('\0', pos, true)
        if nul2 then pos = nul2 + 1 end
      end

      items[#items + 1] = { text = ('%s%s'):format(xy, path), path = vim.fs.joinpath(cwd, path) }
    end

    local ctx = picker.open({
      title = 'Git status',
      query = opts.query,
      on_choose = jump_on_choose,
    })
    ctx.set_items(items)
    return ctx
  end,
}

local function history_source(scope, history_type, apply)
  return {
    title = scope .. ' history',
    start = function(opts)
      local ctx = picker.open({
        title = scope .. ' history',
        query = opts.query,
        on_choose = function(item) apply(item) end,
      })

      local items = {}
      for i = 1, vim.fn.histnr(history_type) do
        local entry = vim.fn.histget(history_type, -i) -- most recent first
        if entry and entry ~= '' then items[#items + 1] = entry end
      end
      ctx.set_items(items)
      return ctx
    end,
  }
end

sources.history_search = history_source('Search', 'search', function(text) set_cmdline('/', text) end)

sources.history_cmd = history_source('Command', 'cmd', function(text) set_cmdline(':', text) end)

function M.get(name) return sources[name] end

function M.all() return sources end

return M
