-- nvim --headless -u NONE -i NONE -l /absolute/path/to/tests/regression.lua
local api = vim.api
local source = debug.getinfo(1, 'S').source:sub(2)
local workspace = vim.fs.dirname(vim.fs.dirname(source))
vim.opt.rtp:prepend(workspace)
vim.o.hidden = true
local temp = vim.fn.tempname() .. '-nvim-regression'
vim.fn.mkdir(temp, 'p')
temp = vim.uv.fs_realpath(temp)
local old_cwd = vim.fn.getcwd()
vim.cmd.cd(temp)
vim.env.JJ_CONFIG = temp .. '/jj-config.toml'
vim.fn.writefile({ 'user.name = "Test"', 'user.email = "test@example.invalid"' }, vim.env.JJ_CONFIG)
local notifications = {}
vim.notify = function(msg) notifications[#notifications + 1] = msg end
local count = 0
local function eq(actual, expected)
  assert(vim.deep_equal(actual, expected), 'expected ' .. vim.inspect(expected) .. ', got ' .. vim.inspect(actual))
end
local function wait_for(fn) assert(vim.wait(5000, fn, 10), 'timed out') end
local function await(run)
  local done, value = false, nil
  run(function(result)
    value = result
    done = true
  end)
  wait_for(function() return done end)
  return value
end
local function command(root, args)
  local res = vim.system(args, { cwd = root, text = true }):wait()
  assert(res.code == 0, table.concat(args, ' ') .. '\n' .. (res.stderr or ''))
  return res.stdout
end
local function git(root, ...) return command(root, { 'git', ... }) end
local function write(root, name, lines)
  vim.fn.mkdir(vim.fs.dirname(root .. '/' .. name), 'p')
  vim.fn.writefile(lines, root .. '/' .. name)
end
local fixture_count = 0
local function fixture()
  fixture_count = fixture_count + 1
  local root = temp .. '/repo' .. fixture_count
  vim.fn.mkdir(root, 'p')
  git(root, 'init', '-q')
  git(root, 'config', 'user.name', 'Test')
  git(root, 'config', 'user.email', 'test@example.invalid')
  git(root, 'config', 'commit.gpgsign', 'false')
  git(root, 'config', 'core.hooksPath', '/dev/null')
  write(root, 'file.txt', { 'base' })
  git(root, 'add', '--', 'file.txt')
  git(root, 'commit', '-qm', 'base')
  return root
end
local picker = require('util.picker')
local vcs = require('util.vcs')
local backend = require('util.vcs.git')
local exec = require('util.vcs.exec')
local function reset_ui()
  picker.close()
  vcs.close()
  vim.cmd('stopinsert')
  vim.cmd('silent! only!')
  vim.cmd('enew!')
  vim.cmd.cd(temp)
end
local function test(name, fn)
  reset_ui()
  fn()
  count = count + 1
  print('PASS ' .. name)
end
local function panel(root)
  vim.cmd.edit(vim.fn.fnameescape(root .. '/file.txt'))
  vcs.setup({ prefer = 'git' })
  vcs.open()
  local buf, win = api.nvim_get_current_buf(), api.nvim_get_current_win()
  wait_for(function() return (api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ''):find('git ·', 1, true) ~= nil end)
  return buf, win
end
local function row(buf, win, section, filename)
  local active = false
  for i, line in ipairs(api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if line:find('▎ ', 1, true) == 1 then active = line:find(section, 1, true) ~= nil end
    if active and line:sub(1, 2) == '  ' and line:find(filename, 1, true) then
      api.nvim_win_set_cursor(win, { i, 0 })
      return i
    end
  end
  error('missing row ' .. section .. '/' .. filename)
end
local function finish(root)
  wait_for(function() return exec.busy[root] == nil end)
  vim.wait(100, function() return false end)
end

local ok, err = xpcall(function()
  test('ANSI trailing and multiline colors', function()
    local lines, spans = require('util.ansi').parse('\27[31mred\nnext')
    eq(lines, { 'red', 'next' })
    eq(spans[1][1][2], 3)
    eq(spans[2][1][2], 4)
  end)

  test('quickfix marked items retain positions', function()
    local root = fixture()
    picker.open({
      title = 'Test',
      items = {
        { text = 'a', path = root .. '/file.txt', lnum = 1, col = 2 },
        { text = 'b', path = root .. '/file.txt' },
      },
    })
    picker._toggle_mark()
    picker._quickfix()
    local qf = vim.fn.getqflist({ title = 1, items = 1 })
    eq(qf.title, 'Test')
    eq(#qf.items, 1)
    eq(qf.items[1].col, 2)
  end)

  test('LSP uses the source window and per-client encoding', function()
    local root = fixture()
    vim.cmd.edit(root .. '/file.txt')
    local source_win = api.nvim_get_current_win()
    local original = vim.lsp.buf_request_sync
    local position
    vim.lsp.buf_request_sync = function(_, _, params)
      position = params({ offset_encoding = 'utf-16' }, api.nvim_get_current_buf())
      return {}
    end
    local success, failure = pcall(require('util.picker_sources').get('lsp').start, { query = 'references' })
    vim.lsp.buf_request_sync = original
    assert(success, failure)
    assert(position, table.concat(notifications, '\n'))
    eq(position.textDocument.uri, vim.uri_from_fname(root .. '/file.txt'))
    eq(api.nvim_get_current_win(), source_win)
    assert(not table.concat(notifications, '\n'):find('LSP request failed', 1, true))
  end)

  test('marked unstaged discard preserves the index', function()
    local root = fixture()
    write(root, 'file.txt', { 'staged' })
    git(root, 'add', 'file.txt')
    write(root, 'file.txt', { 'unstaged' })
    local cached = git(root, 'diff', '--cached')
    local buf, win = panel(root)
    row(buf, win, 'Unstaged', 'file.txt')
    vcs._act('mark')
    local confirm = vim.fn.confirm
    vim.fn.confirm = function() return 1 end
    vcs._act('discard')
    vim.fn.confirm = confirm
    finish(root)
    eq(git(root, 'diff', '--cached'), cached)
    eq(git(root, 'diff'), '')
    eq(vim.fn.readfile(root .. '/file.txt'), { 'staged' })
  end)

  test('wrong-section stage and unstage are no-ops', function()
    local root = fixture()
    write(root, 'file.txt', { 'staged' })
    git(root, 'add', 'file.txt')
    write(root, 'file.txt', { 'unstaged' })
    local cached, work = git(root, 'diff', '--cached'), git(root, 'diff')
    local buf, win = panel(root)
    row(buf, win, 'Staged', 'file.txt')
    vcs._act('stage')
    row(buf, win, 'Unstaged', 'file.txt')
    vcs._act('unstage')
    eq(git(root, 'diff', '--cached'), cached)
    eq(git(root, 'diff'), work)
  end)

  test('rename discard restores both paths', function()
    local root = fixture()
    git(root, 'mv', 'file.txt', 'renamed.txt')
    local status = await(function(cb) backend.collect(root, cb) end)
    local file = status.sections[1].files[1]
    eq(file.old_path, 'file.txt')
    local res = await(function(cb) backend.discard(root, file, cb) end)
    eq(res.code, 0)
    eq(git(root, 'status', '--porcelain'), '')
    eq(vim.fn.filereadable(root .. '/file.txt'), 1)
    eq(vim.fn.filereadable(root .. '/renamed.txt'), 0)
  end)

  test('Git status paths are absolute from a subdirectory', function()
    local root = fixture()
    write(root, 'file.txt', { 'changed' })
    vim.fn.mkdir(root .. '/sub', 'p')
    vim.cmd.cd(root .. '/sub')
    require('util.picker_sources').get('git_status').start({})
    picker._choose_current()
    eq(api.nvim_buf_get_name(0), root .. '/file.txt')
  end)

  test('busy action is rejected even after reopening panel', function()
    local root = fixture()
    write(root, 'file.txt', { 'changed' })
    local buf, win = panel(root)
    row(buf, win, 'Unstaged', 'file.txt')
    local original, callback, calls = backend.stage, nil, 0
    backend.stage = function(_, _, cb)
      calls = calls + 1
      callback = cb
    end
    vcs._act('stage')
    vcs._act('stage')
    eq(calls, 1)
    vcs.close()
    vcs.open()
    vcs._act('stage_all')
    eq(exec.busy[root], 'Updating files')
    callback({ code = 0 })
    backend.stage = original
    finish(root)
    eq(exec.busy[root], nil)
    eq(git(root, 'diff', '--cached'), '')
  end)

  test('hunk stage/unstage preserves unselected changes', function()
    local root = fixture()
    local lines = {}
    for i = 1, 30 do
      lines[i] = 'line ' .. i
    end
    write(root, 'file.txt', lines)
    git(root, 'add', 'file.txt')
    git(root, 'commit', '-qm', 'lines')
    lines[2] = 'first edit'
    lines[25] = 'second edit'
    write(root, 'file.txt', lines)
    local file = { path = 'file.txt', code = 'M' }
    local raw = command(root, backend.diff_cmd(root, file))
    local hunks = require('util.vcs.hunks').parse(raw)
    eq(#hunks, 2)
    eq(await(function(cb) backend.apply_hunk(root, file, raw, hunks[2], cb) end).code, 0)
    local staged = git(root, 'diff', '--cached')
    assert(staged:find('second edit', 1, true))
    assert(not staged:find('first edit', 1, true))
    assert(git(root, 'diff'):find('first edit', 1, true))
    file.staged = true
    raw = command(root, backend.diff_cmd(root, file))
    hunks = require('util.vcs.hunks').parse(raw)
    eq(await(function(cb) backend.apply_hunk(root, file, raw, hunks[1], cb) end).code, 0)
    eq(git(root, 'diff', '--cached'), '')
    file.staged = nil
    raw = command(root, backend.diff_cmd(root, file))
    hunks = require('util.vcs.hunks').parse(raw)
    lines[2] = 'newer edit'
    write(root, 'file.txt', lines)
    assert(await(function(cb) backend.apply_hunk(root, file, raw, hunks[1], cb) end).code ~= 0)
    eq(git(root, 'diff', '--cached'), '')
  end)

  test('inline hunk action stages only selected hunk', function()
    local root = fixture()
    local lines = {}
    for i = 1, 30 do
      lines[i] = 'line ' .. i
    end
    write(root, 'file.txt', lines)
    git(root, 'add', 'file.txt')
    git(root, 'commit', '-qm', 'lines')
    lines[2] = 'first edit'
    lines[25] = 'second edit'
    write(root, 'file.txt', lines)
    local buf, win = panel(root)
    row(buf, win, 'Unstaged', 'file.txt')
    vcs._act('fold')
    wait_for(
      function() return table.concat(api.nvim_buf_get_lines(buf, 0, -1, false), '\n'):find('@@', 1, true) ~= nil end
    )
    for i, line in ipairs(api.nvim_buf_get_lines(buf, 0, -1, false)) do
      if line:find('@@', 1, true) then
        api.nvim_win_set_cursor(win, { i, 0 })
        break
      end
    end
    vcs._act('stage')
    finish(root)
    local cached = git(root, 'diff', '--cached')
    assert(cached:find('first edit', 1, true))
    assert(not cached:find('second edit', 1, true))
  end)

  test('multiline Git commit and failed draft retry', function()
    local root = fixture()
    write(root, 'file.txt', { 'changed' })
    git(root, 'add', 'file.txt')
    eq(await(function(cb) backend.commit(root, 'Title\n\nBody line', cb) end).code, 0)
    eq(git(root, 'log', '-1', '--format=%B'), 'Title\n\nBody line\n\n')
    local submitted, callback
    local buf = require('util.vcs.message').open({
      root = root,
      title = 'Test',
      submit = function(text, cb)
        submitted = text
        callback = cb
      end,
    })
    api.nvim_buf_set_lines(buf, 0, -1, false, { 'Draft', '', 'Details' })
    api.nvim_exec_autocmds('BufWriteCmd', { buffer = buf })
    eq(submitted, 'Draft\n\nDetails')
    callback(false)
    assert(api.nvim_buf_is_valid(buf))
    eq(vim.bo[buf].modifiable, true)
    api.nvim_exec_autocmds('BufWriteCmd', { buffer = buf })
    callback(true)
    eq(api.nvim_buf_is_valid(buf), false)
  end)

  test('rg filters, ignored files, JSON paths and result limits', function()
    local root = fixture()
    write(root, '.gitignore', { 'ignored/' })
    write(root, 'ignored/a.txt', { 'needle' })
    write(root, 'build/a.txt', { 'needle' })
    write(root, 'deps.lock', { 'needle' })
    write(root, 'name:12:34:with space.txt', { 'needle needle needle' })
    local rg = require('util.rg')
    local function run(kind, opts)
      local result, report
      opts.cwd = root
      await(function(cb)
        rg.start(kind, opts, function(items, status)
          result = items
          report = status
          cb(true)
        end)
      end)
      eq(report.code, 0)
      return result, report
    end
    local files = run('files', {})
    local names = {}
    for _, item in ipairs(files) do
      names[item.text] = true
    end
    assert(names['deps.lock'])
    assert(not names['ignored/a.txt'])
    assert(not names['build/a.txt'])
    files = run('files', { ignored = true })
    names = {}
    for _, item in ipairs(files) do
      names[item.text] = true
      assert(not item.text:find('^%.git/'))
    end
    assert(names['ignored/a.txt'])
    assert(names['build/a.txt'])
    local items = run('grep', { query = 'needle', ignored = true })
    local matches = {}
    for _, item in ipairs(items) do
      if item.path:find('name:12:34:', 1, true) then matches[#matches + 1] = item.col end
    end
    eq(matches, { 1, 8, 15 })
    local limited, report = run('grep', { query = 'needle', ignored = true, limit = 2 })
    eq(#limited, 2)
    eq(report.truncated, true)
    rg.setup({ exclude = {} })
    files = run('files', {})
    names = {}
    for _, item in ipairs(files) do
      names[item.text] = true
    end
    assert(names['build/a.txt'])
    rg.setup()
    local called = false
    local cancel = rg.start('files', { cwd = root }, function() called = true end)
    cancel()
    vim.wait(100, function() return false end)
    eq(called, false)
  end)

  test('JJ multiline description, bookmark, revision edit and undo', function()
    if vim.fn.executable('jj') ~= 1 then error('jj is required for the offline backend tests') end
    local root = temp .. '/jj-repo'
    command(temp, { 'jj', 'git', 'init', root })
    write(root, 'file.txt', { 'jj contents' })
    local jj = require('util.vcs.jj')
    eq(await(function(cb) jj.commit(root, 'JJ title\n\nJJ body', cb) end).code, 0)
    eq(command(root, { 'jj', 'log', '--no-graph', '-r', '@', '-T', 'description' }), 'JJ title\n\nJJ body\n')
    local rev = command(root, { 'jj', 'log', '--no-graph', '-r', '@', '-T', 'change_id' })
    eq(await(function(cb) jj.bookmark(root, 'test-bookmark', rev, cb) end).code, 0)
    eq(await(function(cb) jj.new_change(root, cb) end).code, 0)
    eq(await(function(cb) jj.edit(root, rev, cb) end).code, 0)
    eq(await(function(cb) jj.undo(root, cb) end).code, 0)
    eq(command(root, { 'jj', 'log', '--no-graph', '-r', '@-', '-T', 'change_id' }), rev)
  end)
end, debug.traceback)

reset_ui()
vim.cmd.cd(old_cwd)
if ok then
  assert(temp:match('%-nvim%-regression$'))
  vim.fn.delete(temp, 'rf')
  print(('PASS all %d regression tests'):format(count))
else
  io.stderr:write(err .. '\nFixtures retained: ' .. temp .. '\n')
  vim.cmd('cquit 1')
end
