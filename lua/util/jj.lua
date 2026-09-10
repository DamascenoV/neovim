--- Jujutsu integration inspired by mini.git.
---
--- `:JJ` opens an interactive, read-only revision log. `:JJ <args>` runs the
--- corresponding `jj` command in the current buffer's repository.
local JJ = {}

local api = vim.api
local editor_config

local LOG_TEMPLATE = table.concat({
  'commit_id',
  '"\\t"',
  'if(current_working_copy, "1", "0")',
  '"\\t"',
  'change_id.short(12)',
  '"  "',
  'commit_id.short(8)',
  'if(current_working_copy, " @", "")',
  'if(conflict, " conflict", "")',
  'if(empty, " (empty)", "")',
  'if(bookmarks, "  " ++ bookmarks.join(", "), "")',
  'if(description.first_line(), "  " ++ description.first_line(), "  (no description)")',
  '"  "',
  'author.name()',
  '"  "',
  'author.timestamp().ago()',
  '"\\n"',
}, ' ++ ')

local INFO_COMMANDS = {
  annotate = true,
  diff = true,
  evolog = true,
  help = true,
  interdiff = true,
  log = true,
  show = true,
  status = true,
}

local SUBCOMMANDS = {
  'abandon',
  'absorb',
  'arrange',
  'bisect',
  'bookmark',
  'commit',
  'config',
  'converge',
  'describe',
  'diff',
  'diffedit',
  'duplicate',
  'edit',
  'evolog',
  'file',
  'fix',
  'git',
  'gerrit',
  'help',
  'interdiff',
  'log',
  'metaedit',
  'new',
  'next',
  'operation',
  'parallelize',
  'prev',
  'rebase',
  'redo',
  'resolve',
  'restore',
  'revert',
  'root',
  'run',
  'show',
  'sign',
  'simplify-parents',
  'sparse',
  'split',
  'squash',
  'status',
  'tag',
  'undo',
  'unsign',
  'util',
  'version',
  'workspace',
}

JJ.config = {
  job = {
    jj_executable = 'jj',
    timeout = 30000,
  },
  command = {
    split = 'horizontal',
  },
  log = {
    limit = 300,
    revset = 'all()',
  },
}

local state ---@type table?

local function notify(message, level)
  if not message or message == '' then return end
  vim.notify(message, level or vim.log.levels.INFO, { title = 'JJ' })
end

local function validate_config(config)
  if type(config) ~= 'table' then error('`config` must be a table') end
  if not vim.tbl_contains({ 'horizontal', 'vertical', 'tab', 'auto' }, config.command.split) then
    error('`config.command.split` must be "horizontal", "vertical", "tab", or "auto"')
  end
  if type(config.job.jj_executable) ~= 'string' then error('`config.job.jj_executable` must be a string') end
  if type(config.job.timeout) ~= 'number' or config.job.timeout < 0 then
    error('`config.job.timeout` must be a non-negative number')
  end
  if type(config.log.limit) ~= 'number' or config.log.limit < 1 then
    error('`config.log.limit` must be a positive number')
  end
  if type(config.log.revset) ~= 'string' or config.log.revset == '' then
    error('`config.log.revset` must be a non-empty string')
  end
end

local function start_dir()
  local name = api.nvim_buf_get_name(0)
  if name == '' or vim.bo.buftype ~= '' then return vim.fn.getcwd() end
  if vim.fn.isdirectory(name) == 1 then return name end
  return vim.fs.dirname(name) or vim.fn.getcwd()
end

---@param cwd string?
---@return string?
function JJ.get_root(cwd)
  cwd = cwd or start_dir()
  local result = vim
    .system({ JJ.config.job.jj_executable, 'root' }, {
      cwd = cwd,
      text = true,
      timeout = JJ.config.job.timeout,
    })
    :wait()
  if result.code ~= 0 then return nil end
  local root = vim.trim(result.stdout or '')
  return root ~= '' and root or nil
end

local function command(args)
  local result = { JJ.config.job.jj_executable, '--no-pager', '--color=never' }
  vim.list_extend(result, args)
  return result
end

local function run(args, cwd, callback, opts)
  opts = opts or {}
  local cmd = command(args)
  vim.system(cmd, {
    cwd = cwd,
    text = true,
    timeout = JJ.config.job.timeout,
    env = vim.tbl_extend('force', { NO_COLOR = '1', TERM = 'dumb' }, opts.env or {}),
  }, function(result)
    vim.schedule(function() callback(result, cmd) end)
  end)
end

local function trigger(pattern, data)
  api.nvim_exec_autocmds('User', { pattern = pattern, modeline = false, data = data })
end

local function split_modifier(mods)
  if mods:find('vertical') or mods:find('horizontal') or mods:find('tab') then return mods end
  local split = JJ.config.command.split
  if split == 'auto' then split = #api.nvim_tabpage_list_wins(0) == 1 and 'horizontal' or 'tab' end
  return split .. ' ' .. mods
end

local function has_split_modifier(mods)
  return mods:find('vertical') ~= nil or mods:find('horizontal') ~= nil or mods:find('tab') ~= nil
end

local function ensure_server()
  if vim.v.servername ~= '' then return true end
  local ok = pcall(vim.fn.serverstart, vim.fn.tempname() .. '-jj-nvim')
  return ok and vim.v.servername ~= ''
end

local function ensure_editor_config()
  if editor_config and vim.fn.filereadable(editor_config) == 1 then return true end
  if not ensure_server() then
    notify('Could not start the Neovim RPC server required by the JJ editor', vim.log.levels.ERROR)
    return false
  end

  editor_config = vim.fn.tempname() .. '-jj-editor.lua'
  local lines = {
    'local inspect = vim.inspect',
    ('local channel = vim.fn.sockconnect("pipe", %s, { rpc = true })'):format(vim.inspect(vim.v.servername)),
    'local command = string.format(',
    '  "JJ._edit(%s, %s, %s, %s)",',
    '  inspect(vim.fn.argv(0)),',
    '  inspect(vim.v.servername),',
    '  inspect(vim.env.NVIM_JJ_MODS or ""),',
    '  inspect(tonumber(vim.env.NVIM_JJ_SOURCE_WIN))',
    ')',
    'vim.rpcrequest(channel, "nvim_exec_lua", command, {})',
  }
  local ok = vim.fn.writefile(lines, editor_config) == 0
  if not ok then notify('Could not create the temporary JJ editor config', vim.log.levels.ERROR) end
  return ok
end

local function editor_environment(mods, source_win)
  if not ensure_editor_config() then return nil end
  local editor = vim.fn.shellescape(vim.v.progpath) .. ' --clean --headless -u ' .. vim.fn.shellescape(editor_config)
  return {
    JJ_EDITOR = editor,
    NVIM_JJ_MODS = mods or '',
    NVIM_JJ_SOURCE_WIN = tostring(source_win),
  }
end

local function open_split(lines, opts)
  opts = opts or {}
  if opts.source_win and api.nvim_win_is_valid(opts.source_win) then api.nvim_set_current_win(opts.source_win) end
  local source_win = api.nvim_get_current_win()
  local mods = split_modifier(opts.mods or '')
  if mods:find('tab') then
    vim.cmd(mods .. ' new')
  else
    vim.cmd(mods .. ' new')
    if mods:find('horizontal') then
      api.nvim_win_set_height(0, math.max(math.floor(vim.o.lines / 2), 12))
      vim.wo.winfixheight = true
    end
  end

  local target_win = api.nvim_get_current_win()
  local buf = api.nvim_get_current_buf()
  pcall(api.nvim_buf_set_name, buf, ('jj://%s'):format(opts.name or 'output'))
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].buflisted = false
  vim.bo[buf].modifiable = true
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = opts.filetype or 'jj'
  vim.wo[target_win].wrap = false
  vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = buf, silent = true, desc = 'Close JJ output' })
  return source_win, target_win, buf
end

local function report(result)
  if result.code == 0 then return true end
  local message = vim.trim(result.stderr or '')
  if message == '' then message = vim.trim(result.stdout or '') end
  notify(message ~= '' and message or ('jj exited with code %d'):format(result.code), vim.log.levels.ERROR)
  return false
end

---@param args string[]
---@param opts table?
function JJ.run(args, opts)
  opts = opts or {}
  if vim.fn.executable(JJ.config.job.jj_executable) ~= 1 then
    notify(('There is no `%s` executable'):format(JJ.config.job.jj_executable), vim.log.levels.ERROR)
    return
  end
  local root = opts.cwd or JJ.get_root()
  if not root then
    notify('Current buffer is not inside a JJ workspace', vim.log.levels.ERROR)
    return
  end

  local expanded = vim.tbl_map(vim.fn.expandcmd, args)
  local source_win = api.nvim_get_current_win()
  local env = editor_environment(opts.mods, source_win)
  if not env then return end
  run(expanded, root, function(result, cmd)
    local data = {
      cmd_input = opts.cmd_input,
      command = cmd,
      cwd = root,
      exit_code = result.code,
      jj_command = cmd,
      jj_subcommand = expanded[1],
      stderr = result.stderr or '',
      stdout = result.stdout or '',
    }
    trigger('JJCommandDone', data)
    if not report(result) then
      if opts.on_exit then opts.on_exit(result) end
      return
    end

    local stdout = vim.trim(result.stdout or '')
    local stderr = vim.trim(result.stderr or '')
    local subcommand = expanded[1]
    local mods = opts.mods or ''
    local silent = mods:find('silent') ~= nil and mods:find('unsilent') == nil
    if silent then
      -- The command still runs and emits JJCommandDone, but does not show output.
    elseif stdout ~= '' and (INFO_COMMANDS[subcommand] or has_split_modifier(mods)) then
      data.win_source, data.win_stdout = open_split(vim.split(stdout, '\n'), {
        mods = mods,
        name = table.concat(expanded, ' '),
        filetype = subcommand == 'diff' and 'diff' or 'jj',
        source_win = source_win,
      })
      trigger('JJCommandSplit', data)
    else
      notify(table.concat(vim.tbl_filter(function(value) return value ~= '' end, { stdout, stderr }), '\n'))
    end
    for _, buf in ipairs(api.nvim_list_bufs()) do
      if api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' then pcall(vim.cmd, 'checktime ' .. buf) end
    end
    if opts.on_exit then opts.on_exit(result) end
  end, { env = env })
end

---Open a file requested through `$JJ_EDITOR` in the current Neovim instance.
---This is called over RPC by a short-lived headless Neovim process.
---@param path string
---@param helper_server string
---@param mods string
---@param source_win integer?
function JJ._edit(path, helper_server, mods, source_win)
  if source_win and api.nvim_win_is_valid(source_win) then api.nvim_set_current_win(source_win) end
  vim.cmd(split_modifier(mods or '') .. ' split ' .. vim.fn.fnameescape(path))
  local buf, win = api.nvim_get_current_buf(), api.nvim_get_current_win()
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'gitcommit'
  if not (mods or ''):find('vertical') and not (mods or ''):find('tab') then
    api.nvim_win_set_height(win, math.max(math.floor(vim.o.lines / 3), 10))
    vim.wo[win].winfixheight = true
  end
  vim.wo[win].winbar = ' JJ editor · :write then :close to continue '

  local autocmd
  local function finish(event)
    local should_finish = event.buf == buf or (event.event == 'WinClosed' and tonumber(event.match) == win)
    if not should_finish then return end
    pcall(api.nvim_del_autocmd, autocmd)
    local connected, channel = pcall(vim.fn.sockconnect, 'pipe', helper_server, { rpc = true })
    if connected then pcall(vim.rpcnotify, channel, 'nvim_exec2', 'quitall!', {}) end
  end
  autocmd = api.nvim_create_autocmd({ 'WinClosed', 'BufDelete', 'BufWipeout', 'VimLeave' }, {
    nested = true,
    callback = finish,
    desc = 'Finish JJ editor process',
  })
end

local function is_active(s)
  return state == s
    and s.win
    and api.nvim_win_is_valid(s.win)
    and s.buf
    and api.nvim_buf_is_valid(s.buf)
    and api.nvim_win_get_buf(s.win) == s.buf
end

local function current_row(s)
  if not is_active(s) then return nil end
  return s.rows[api.nvim_win_get_cursor(s.win)[1]]
end

local function set_preview(s, lines, title)
  if not (s.preview_buf and api.nvim_buf_is_valid(s.preview_buf)) then return end
  vim.bo[s.preview_buf].modifiable = true
  api.nvim_buf_set_lines(s.preview_buf, 0, -1, false, lines)
  vim.bo[s.preview_buf].modifiable = false
  if s.preview_win and api.nvim_win_is_valid(s.preview_win) then vim.wo[s.preview_win].winbar = ' ' .. title .. ' ' end
end

local function close_preview(s)
  s.preview_generation = s.preview_generation + 1
  if s.preview_win and api.nvim_win_is_valid(s.preview_win) then pcall(api.nvim_win_close, s.preview_win, true) end
  if s.preview_buf and api.nvim_buf_is_valid(s.preview_buf) then
    pcall(api.nvim_buf_delete, s.preview_buf, { force = true })
  end
  s.preview_win, s.preview_buf = nil, nil
end

local function ensure_preview(s)
  if s.preview_win and api.nvim_win_is_valid(s.preview_win) then return true end
  s.preview_buf = api.nvim_create_buf(false, true)
  vim.bo[s.preview_buf].buftype = 'nofile'
  vim.bo[s.preview_buf].bufhidden = 'wipe'
  vim.bo[s.preview_buf].swapfile = false
  vim.bo[s.preview_buf].filetype = 'jj'
  local ok, preview_win = pcall(api.nvim_open_win, s.preview_buf, false, { split = 'right', win = s.win })
  if not ok then
    pcall(api.nvim_buf_delete, s.preview_buf, { force = true })
    s.preview_buf = nil
    notify('Could not open JJ preview: ' .. tostring(preview_win), vim.log.levels.ERROR)
    return false
  end
  s.preview_win = preview_win
  vim.wo[preview_win].number = false
  vim.wo[preview_win].relativenumber = false
  vim.wo[preview_win].wrap = false
  return true
end

local function show_current(s)
  local row = current_row(s)
  if not (row and row.revision and ensure_preview(s)) then return end
  s.preview_generation = s.preview_generation + 1
  local generation = s.preview_generation
  set_preview(s, { 'Loading ' .. row.revision:sub(1, 12) .. '…' }, 'JJ show · loading…')
  run({ 'show', '--at-operation', '@', '--ignore-working-copy', '--stat', '-r', row.revision }, s.root, function(result)
    if not is_active(s) or generation ~= s.preview_generation or not report(result) then return end
    set_preview(s, vim.split(result.stdout or '', '\n', { trimempty = true }), 'JJ show · ' .. row.revision:sub(1, 12))
  end)
end

local function render_log(s)
  if not is_active(s) then return end
  local rows = {
    { text = ('JJ revisions · %s'):format(s.revset), hl = 'Title' },
    { text = '  <CR>/d show · p preview · L revset · R refresh · / search · q close', hl = 'Comment' },
    { text = '' },
  }
  vim.list_extend(rows, s.data)
  if #s.data == 0 and not s.loading then
    rows[#rows + 1] = { text = '  No revisions in this revset', hl = 'Comment' }
  end
  s.rows = rows

  vim.bo[s.buf].modifiable = true
  api.nvim_buf_set_lines(s.buf, 0, -1, false, vim.tbl_map(function(row) return row.text end, rows))
  vim.bo[s.buf].modifiable = false
  api.nvim_buf_clear_namespace(s.buf, s.namespace, 0, -1)
  for index, row in ipairs(rows) do
    local hl = row.hl or (row.working_copy and 'Special' or (row.revision and 'Identifier' or 'Comment'))
    api.nvim_buf_set_extmark(s.buf, s.namespace, index - 1, 0, { end_col = #row.text, hl_group = hl })
    if row.graph_end and row.graph_end > 0 then
      api.nvim_buf_set_extmark(s.buf, s.namespace, index - 1, 0, {
        end_col = row.graph_end,
        hl_group = 'Comment',
        priority = 60,
      })
    end
  end

  local target = 1
  for index, row in ipairs(rows) do
    if s.last_revision and row.revision == s.last_revision then
      target = index
      break
    elseif target == 1 and row.revision then
      target = index
    end
  end
  local row = rows[target]
  if row and row.revision then s.last_revision = row.revision end
  api.nvim_win_set_cursor(s.win, { target, 0 })
  vim.wo[s.win].winbar = (' JJ log · %s%s '):format(s.revset, s.loading and ' · loading…' or '')
end

local function refresh_log(s, revset)
  if not is_active(s) then return end
  s.generation = s.generation + 1
  local generation = s.generation
  local requested = revset or s.revset
  s.loading = true
  render_log(s)
  run(
    {
      'log',
      '--at-operation',
      '@',
      '--ignore-working-copy',
      '-r',
      requested,
      '--limit',
      tostring(JJ.config.log.limit),
      '-T',
      LOG_TEMPLATE,
    },
    s.root,
    function(result)
      if not is_active(s) or generation ~= s.generation then return end
      s.loading = false
      if not report(result) then
        render_log(s)
        return
      end

      local rows = {}
      for line in vim.gsplit(result.stdout or '', '\n', { trimempty = true }) do
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
      s.revset = requested
      s.data = rows
      render_log(s)
      if s.preview_win and api.nvim_win_is_valid(s.preview_win) then show_current(s) end
    end
  )
end

function JJ.close_log()
  local s = state
  if not s then return end
  state = nil
  s.generation = s.generation + 1
  close_preview(s)
  pcall(api.nvim_del_augroup_by_id, s.augroup)
  if s.win and api.nvim_win_is_valid(s.win) then pcall(api.nvim_win_close, s.win, true) end
  if s.buf and api.nvim_buf_is_valid(s.buf) then pcall(api.nvim_buf_delete, s.buf, { force = true }) end
  if s.source_win and api.nvim_win_is_valid(s.source_win) then pcall(api.nvim_set_current_win, s.source_win) end
end

---@param opts table?
function JJ.log(opts)
  opts = opts or {}
  local root = opts.cwd or JJ.get_root()
  if not root then
    notify('Current buffer is not inside a JJ workspace', vim.log.levels.ERROR)
    return
  end
  if state then JJ.close_log() end

  local source_win = api.nvim_get_current_win()
  local _, win, buf = open_split({ 'Loading JJ log…' }, { mods = opts.mods, name = 'log', filetype = 'jjlog' })
  local s = {
    buf = buf,
    data = {},
    generation = 0,
    last_revision = nil,
    loading = false,
    namespace = api.nvim_create_namespace('util.jj.log'),
    preview_generation = 0,
    revset = opts.revset or JJ.config.log.revset,
    root = root,
    rows = {},
    source_win = source_win,
    win = win,
  }
  state = s
  vim.wo[win].cursorline = true
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'

  vim.keymap.set('n', 'q', JJ.close_log, { buffer = buf, silent = true, desc = 'Close JJ log' })
  vim.keymap.set('n', '<CR>', function() show_current(s) end, { buffer = buf, silent = true, desc = 'Show revision' })
  vim.keymap.set('n', 'd', function() show_current(s) end, { buffer = buf, silent = true, desc = 'Show revision' })
  vim.keymap.set('n', 'p', function()
    if s.preview_win and api.nvim_win_is_valid(s.preview_win) then
      close_preview(s)
    else
      show_current(s)
    end
  end, { buffer = buf, silent = true, desc = 'Toggle revision preview' })
  vim.keymap.set('n', 'R', function() refresh_log(s) end, { buffer = buf, silent = true, desc = 'Refresh JJ log' })
  vim.keymap.set('n', '<C-r>', function() refresh_log(s) end, { buffer = buf, silent = true, desc = 'Refresh JJ log' })
  vim.keymap.set('n', 'L', function()
    vim.ui.input({ prompt = 'JJ revset: ', default = s.revset }, function(value)
      value = value and vim.trim(value) or ''
      if is_active(s) and value ~= '' then refresh_log(s, value) end
    end)
  end, { buffer = buf, silent = true, desc = 'Change JJ revset' })

  s.augroup = api.nvim_create_augroup(('util.jj.log.%d'):format(buf), { clear = true })
  api.nvim_create_autocmd('CursorMoved', {
    group = s.augroup,
    buffer = buf,
    callback = function()
      local row = current_row(s)
      if row and row.revision then
        s.last_revision = row.revision
        if s.preview_win and api.nvim_win_is_valid(s.preview_win) then show_current(s) end
      end
    end,
  })
  api.nvim_create_autocmd('BufWipeout', {
    group = s.augroup,
    buffer = buf,
    once = true,
    callback = function()
      if state == s then JJ.close_log() end
    end,
  })

  refresh_log(s)
end

function JJ._refresh()
  if state then refresh_log(state) end
end

function JJ._show()
  if state then show_current(state) end
end

function JJ._set_revset(revset)
  if state then refresh_log(state, revset) end
end

local function complete(arglead)
  return vim.tbl_filter(function(value) return vim.startswith(value, arglead) end, SUBCOMMANDS)
end

local function command_impl(input)
  if #input.fargs == 0 then
    JJ.log({ mods = input.mods })
  else
    JJ.run(input.fargs, { cmd_input = input, mods = input.mods })
  end
end

---@param config table?
function JJ.setup(config)
  JJ.config = vim.tbl_deep_extend('force', vim.deepcopy(JJ.config), config or {})
  validate_config(JJ.config)
  _G.JJ = JJ
  if vim.fn.executable(JJ.config.job.jj_executable) ~= 1 then
    notify(('There is no `%s` executable'):format(JJ.config.job.jj_executable), vim.log.levels.WARN)
  end
  pcall(api.nvim_del_user_command, 'JJ')
  api.nvim_create_user_command('JJ', command_impl, {
    bang = true,
    complete = complete,
    desc = 'Run JJ or open its interactive log',
    nargs = '*',
  })
end

return JJ
