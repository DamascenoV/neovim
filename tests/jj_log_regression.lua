-- nvim --headless -u NONE -i NONE -l /absolute/path/to/tests/jj_log_regression.lua
local api = vim.api
local source = debug.getinfo(1, 'S').source:sub(2)
local workspace = vim.fs.dirname(vim.fs.dirname(source))
vim.opt.rtp:prepend(workspace)
vim.o.hidden = true

local temp = vim.fn.tempname() .. '-jj-log-regression'
vim.fn.mkdir(temp, 'p')
temp = vim.uv.fs_realpath(temp)
vim.env.JJ_CONFIG = temp .. '/jj-config.toml'
vim.fn.writefile({ 'user.name = "Test"', 'user.email = "test@example.invalid"' }, vim.env.JJ_CONFIG)

local function command(root, args)
  local res = vim.system(args, { cwd = root, text = true }):wait()
  assert(res.code == 0, table.concat(args, ' ') .. '\n' .. (res.stderr or ''))
  return res.stdout or ''
end

local function wait_for(fn) assert(vim.wait(5000, fn, 10), 'timed out') end

local function current_operation(root)
  return vim.trim(command(root, {
    'jj',
    'op',
    'log',
    '--at-operation',
    '@',
    '--ignore-working-copy',
    '--no-graph',
    '--limit',
    '1',
    '-T',
    'id',
  }))
end

local ok, err = xpcall(function()
  local root = temp .. '/repo'
  command(temp, { 'jj', 'git', 'init', root })
  command(root, { 'jj', 'describe', '-m', 'parent-a' })
  local parent_a = vim.trim(command(root, { 'jj', 'log', '--no-graph', '-r', '@', '-T', 'commit_id' }))
  command(root, { 'jj', 'new', 'root()' })
  command(root, { 'jj', 'describe', '-m', 'parent-b' })
  local parent_b = vim.trim(command(root, { 'jj', 'log', '--no-graph', '-r', '@', '-T', 'commit_id' }))
  command(root, { 'jj', 'new', '--', parent_a, parent_b })

  local panel_buf = api.nvim_create_buf(false, true)
  local panel_win = api.nvim_get_current_win()
  api.nvim_win_set_buf(panel_win, panel_buf)
  local before = current_operation(root)
  require('util.vcs.jj').log(root, panel_win)
  wait_for(function() return vim.bo.filetype == 'jjlog' end)
  local log_win = api.nvim_get_current_win()
  wait_for(function()
    local text = table.concat(api.nvim_buf_get_lines(0, 0, -1, false), '\n')
    return text:find('parent%-a') and text:find('parent%-b') and text:find('├')
  end)

  local jj_log = require('util.vcs.jj_log')
  local first_line = api.nvim_win_get_cursor(log_win)[1]
  jj_log._toggle()
  assert((api.nvim_get_option_value('winbar', { win = log_win }) or ''):find('1 selected', 1, true))
  jj_log._move(1)
  assert(api.nvim_win_get_cursor(log_win)[1] > first_line)

  jj_log._preview()
  wait_for(function()
    for _, winnr in ipairs(api.nvim_list_wins()) do
      local bufnr = api.nvim_win_get_buf(winnr)
      if api.nvim_get_option_value('filetype', { buf = bufnr }) == 'jj' then
        local text = table.concat(api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')
        if text:find('Commit ID:', 1, true) then return true end
      end
    end
    return false
  end)

  local original_input = vim.ui.input
  vim.ui.input = function(_, cb) cb('@') end
  jj_log._revset()
  vim.ui.input = original_input
  wait_for(
    function() return (api.nvim_get_option_value('winbar', { win = log_win }) or ''):find('JJ log · @', 1, true) ~= nil end
  )
  assert(current_operation(root) == before, 'read-only JJ log created an operation')

  jj_log.close()
  assert(api.nvim_get_current_win() == panel_win)

  local pending, show_callback, created_parents, new_done = {}, nil, nil, nil
  local parent_refreshes = 0
  local fake_backend = {
    log_data = function(_, revset, cb) pending[revset] = cb end,
    show = function(_, _, cb) show_callback = cb end,
    new_change = function(_, cb, revisions)
      created_parents = vim.deepcopy(revisions)
      new_done = cb
    end,
  }
  jj_log.open({
    root = root,
    panel_win = panel_win,
    panel_buf = panel_buf,
    backend = fake_backend,
    on_change = function() parent_refreshes = parent_refreshes + 1 end,
  })
  pending['all()']({ code = 0, stdout = '', stderr = '' }, {
    { text = '@  first revision', revision = string.rep('a', 40), working_copy = true },
    { text = '○  second revision', revision = string.rep('b', 40) },
  })
  local fake_log_win = api.nvim_get_current_win()

  local original_confirm = vim.fn.confirm
  vim.fn.confirm = function() return 1 end
  jj_log._visual_action('new', 4, 5)
  vim.fn.confirm = original_confirm
  assert(#created_parents == 2, 'Visual Line action did not use both revisions')
  assert(created_parents[1] == string.rep('a', 40) and created_parents[2] == string.rep('b', 40))
  assert(require('util.vcs.exec').busy[root] == 'Create change', 'JJ log mutation did not acquire repository lock')
  assert(parent_refreshes == 0, 'parent refreshed before mutation completed')
  new_done({ code = 0, stdout = '', stderr = '' })
  assert(require('util.vcs.exec').busy[root] == nil, 'JJ log mutation did not release repository lock')
  assert(parent_refreshes == 1, 'mutation did not refresh the parent VCS panel')
  pending['all()']({ code = 0, stdout = '', stderr = '' }, {
    { text = '@  refreshed revision', revision = string.rep('d', 40), working_copy = true },
  })

  local inputs = { 'first()', 'second()' }
  original_input = vim.ui.input
  vim.ui.input = function(_, cb) cb(table.remove(inputs, 1)) end
  jj_log._revset()
  jj_log._revset()
  vim.ui.input = original_input
  pending['first()']({ code = 0, stdout = '', stderr = '' }, {
    { text = 'first result', revision = string.rep('b', 40) },
  })
  assert((api.nvim_get_option_value('winbar', { win = fake_log_win }) or ''):find('JJ log · all()', 1, true))
  pending['second()']({ code = 0, stdout = '', stderr = '' }, {
    { text = 'second result', revision = string.rep('c', 40) },
  })
  assert((api.nvim_get_option_value('winbar', { win = fake_log_win }) or ''):find('JJ log · second()', 1, true))

  jj_log._show()
  assert(show_callback, 'preview command was not requested')
  jj_log.close()
  show_callback({ code = 0, stdout = 'stale preview', stderr = '' })
  assert(api.nvim_get_current_win() == panel_win)
end, debug.traceback)

vim.fn.delete(temp, 'rf')
if not ok then
  io.stderr:write(err .. '\n')
  vim.cmd('cquit 1')
end
print('PASS interactive JJ log regression')
