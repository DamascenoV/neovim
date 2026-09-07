local M = {}
local defaults = {
  exclude = {
    'node_modules',
    'dist',
    'build',
    'target',
    'out',
    'coverage',
    '*.log',
    '*.tmp',
    '*.cache',
    '*.bak',
    '*.swp',
    '*.swo',
    '*.DS_Store',
  },
  max_files = 30000,
  max_results = 10000,
  max_bytes = 8 * 1024 * 1024,
}
local config = vim.deepcopy(defaults)

function M.setup(opts)
  config = vim.tbl_extend('force', vim.deepcopy(defaults), opts or {})
  for _, key in ipairs({ 'max_files', 'max_results', 'max_bytes' }) do
    assert(
      type(config[key]) == 'number' and config[key] >= 1 and config[key] == math.floor(config[key]),
      key .. ' must be a positive integer'
    )
  end
  assert(type(config.exclude) == 'table', 'exclude must be a list of globs')
  for _, glob in ipairs(config.exclude) do
    assert(type(glob) == 'string', 'exclude must contain strings')
  end
end

function M.args(kind, query, ignored)
  local args = { 'rg', '--hidden', '--color=never', '--glob=!.git', '--glob=!.jj' }
  if ignored then
    args[#args + 1] = '--no-ignore'
  else
    for _, glob in ipairs(config.exclude) do
      args[#args + 1] = '--glob=!' .. glob
    end
  end
  if kind == 'files' then
    vim.list_extend(args, { '--files', '--null' })
  else
    vim.list_extend(args, { '--json', '--smart-case', '--', query, '.' })
  end
  return args
end

local function display(text) return text:gsub('[\r\n]', ' ') end

---Bounded streaming collection; returns a silent cancellation function.
function M.start(kind, opts, done)
  local cwd = opts.cwd
  local limit = opts.limit or (kind == 'files' and config.max_files or config.max_results)
  local items, pending, stderr = {}, '', ''
  local bytes, truncated, cancelled = 0, false, false
  local job
  local function stop()
    if job then pcall(job.kill, job, 'sigterm') end
  end
  local function add(record)
    if kind == 'files' then
      if #items >= limit and record ~= '' then truncated = true; return end
      if record ~= '' then items[#items + 1] = { text = display(record), path = vim.fs.joinpath(cwd, record) } end
      return
    end
    local ok, event = pcall(vim.json.decode, record)
    if not ok or event.type ~= 'match' then return end
    local data = event.data
    local path = data.path.text or (data.path.bytes and vim.base64.decode(data.path.bytes))
    local line = data.lines.text or (data.lines.bytes and vim.base64.decode(data.lines.bytes))
    if not path or not line then return end
    for _, match in ipairs(data.submatches) do
      if #items >= limit then
        truncated = true
        return
      end
      local col = match.start + 1
      items[#items + 1] = {
        text = display(('%s:%d:%d:%s'):format(path, data.line_number, col, line:gsub('[\r\n]+$', ''))),
        path = vim.fs.joinpath(cwd, path),
        lnum = data.line_number,
        col = col,
      }
    end
  end
  local separator = kind == 'files' and '\0' or '\n'
  local ok, result = pcall(vim.system, M.args(kind, opts.query, opts.ignored), {
    cwd = cwd,
    stdout = function(err, chunk)
      if err then
        stderr = tostring(err)
        return
      end
      if not chunk or cancelled or truncated then return end
      bytes = bytes + #chunk
      if bytes > config.max_bytes then
        truncated = true
        stop()
        return
      end
      pending = pending .. chunk
      local from = 1
      while true do
        local at = pending:find(separator, from, true)
        if not at then break end
        add(pending:sub(from, at - 1))
        from = at + #separator
        if truncated then
          stop()
          break
        end
      end
      pending = truncated and '' or pending:sub(from)
    end,
    stderr = function(_, chunk)
      if chunk then stderr = (stderr .. chunk):sub(1, 4096) end
    end,
  }, function(res)
    vim.schedule(function()
      if cancelled then return end
      if not truncated and pending ~= '' and #items < limit then add(pending) end
      done(items, { code = truncated and 0 or res.code, error = stderr, truncated = truncated })
    end)
  end)
  if ok then
    job = result
    if truncated then stop() end
  else
    vim.schedule(function()
      if not cancelled then done({}, { code = -1, error = tostring(result) }) end
    end)
  end
  return function()
    cancelled = true
    stop()
  end
end

return M
