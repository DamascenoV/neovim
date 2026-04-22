---@module "compile"
---@description Emacs-style compilation mode for Neovim
--- Provides async command execution with error parsing, quickfix integration,
--- and jump-to-error functionality.

local M = {}

-------------------------------------------------------------------------------
-- Module State
-------------------------------------------------------------------------------

M.last_command = nil -- Stores the last executed command for recompilation
M.bufnr = nil -- Buffer number for the compilation output window
M.job_id = nil -- Job ID of the currently running compilation process
M.current_error_idx = 0 -- Current position in the quickfix error list

-------------------------------------------------------------------------------
-- Configuration
-------------------------------------------------------------------------------

local config = {
  buffer_name = '*COMPILATION*', -- Name displayed in the buffer list
  split_direction = 'botright', -- Where to open the split (botright, topleft, etc.)
  split_size = 12, -- Height of the compilation window in lines
  auto_close_on_success = false, -- Close window automatically on successful build
  auto_scroll = true, -- Auto-scroll to bottom as output appears
  clear_on_compile = true, -- Clear buffer before each new compilation
  -- Detectors check for project files to auto-detect build commands.
  -- First matching detector wins. Order matters for projects with multiple build systems.
  detectors = { -- Custom project detectors (file, cmd, lang)
    { file = 'Cargo.toml', cmd = 'cargo build', lang = 'rust' },
    { file = 'go.mod', cmd = 'go build ./...', lang = 'go' },
    { file = 'build.zig', cmd = 'zig build', lang = 'zig' },
    { file = 'mix.exs', cmd = 'mix compile', lang = 'elixir' },
    { file = 'composer.json', cmd = 'php artisan serve', lang = 'php' },
    { file = 'package.json', cmd = 'npm run build', lang = 'typescript' },
    { file = 'Makefile', cmd = 'make', lang = nil },
    { file = 'CMakeLists.txt', cmd = 'cmake --build build', lang = 'c' },
  },
}

--- Configure the compile module with custom options
---@param opts table|nil Configuration options to override defaults
function M.setup(opts) config = vim.tbl_deep_extend('force', config, opts or {}) end

local NOTIFY_TITLE = 'Compile Mode' -- Title shown in notification popups

-------------------------------------------------------------------------------
-- Error Format Definitions
-------------------------------------------------------------------------------
-- Language-specific errorformat strings for parsing compiler output.
-- These patterns are used by :cgetexpr to populate the quickfix list.
-- Format: %f=file, %l=line, %c=column, %t=type, %m=message

local efm_map = {
  ['rust'] = [[%f:%l:%c:\ %t%*[^:]:\ %m]],
  ['zig'] = [[%f:%l:%c:\ %m,%f:%l:\ %m]],
  ['go'] = [[%f:%l:%c:\ %m,%f:%l:\ %m]],
  ['elixir'] = [[%E**\ (%t%s)\ %f:%l:\ %m,%W%f:%l:\ warning:\ %m,%C%.%#]],
  ['php'] = [[%m\ in\ %f\ on\ line\ %l]],
  ['typescript'] = [[%f(%l\,%c):\ %m,%E%f:%l:%c\ -\ error\ %m,%W%f:%l:%c\ -\ warning\ %m]],
  ['javascript'] = [[%f:%l:%c:\ %m]],
  ['c'] = [[%f:%l:%c:\ %m]],
  ['cpp'] = [[%f:%l:%c:\ %m]],
  ['python'] = [[%E\ \ File\ \"%f\"\,\ line\ %l,%C\ \ \ \ %p^,%Z%t%s:\ %m,%f:%l:\ %m]],
}

-------------------------------------------------------------------------------
-- Project Detection
-------------------------------------------------------------------------------

--- Detect project type by checking for build system files in cwd
---@return table|nil detector The matched detector or nil if none found
local function get_detector()
  local cwd = vim.fn.getcwd()
  for _, detector in ipairs(config.detectors) do
    if vim.uv.fs_stat(cwd .. '/' .. detector.file) then return detector end
  end
  return nil
end

-------------------------------------------------------------------------------
-- Syntax Highlighting
-------------------------------------------------------------------------------

local highlights_initialized = false

--- Define highlight groups for the compilation buffer
--- Links to existing highlight groups for consistency with colorscheme
local function setup_highlights()
  local hl = vim.api.nvim_set_hl

  -- Header highlights (command info at top of buffer)
  hl(0, 'CompilationCommand', { link = 'Title' })
  hl(0, 'CompilationTimestamp', { link = 'Comment' })
  hl(0, 'CompilationSeparator', { link = 'NonText' })

  -- Status highlights (exit codes)
  hl(0, 'CompilationSuccess', { link = 'DiagnosticOk' })
  hl(0, 'CompilationError', { link = 'DiagnosticError' })
  hl(0, 'CompilationWarning', { link = 'DiagnosticWarn' })

  -- File location highlights (file:line:col references)
  hl(0, 'CompilationFilePath', { link = 'Directory' })
  hl(0, 'CompilationLineNr', { link = 'Number' })
  hl(0, 'CompilationColNr', { link = 'Number' })

  -- Message type highlights (error/warning/note keywords)
  hl(0, 'CompilationErrorMsg', { link = 'ErrorMsg' })
  hl(0, 'CompilationWarningMsg', { link = 'WarningMsg' })
  hl(0, 'CompilationInfo', { link = 'MoreMsg' })
  hl(0, 'CompilationNote', { link = 'Comment' })
end

--- Initialize highlights once and set up autocmd to reapply on colorscheme change
local function ensure_highlights()
  if highlights_initialized then return end
  setup_highlights()
  highlights_initialized = true

  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('CompilationHighlights', { clear = true }),
    callback = setup_highlights,
  })
end

-------------------------------------------------------------------------------
-- Location Parsing & Navigation
-------------------------------------------------------------------------------

--- Parse file location from a line of compiler output
--- Supports formats: file.ext:line:col, file.ext:line, file.ext(line,col)
---@param line string The line to parse
---@return string|nil file The file path or nil if no match
---@return number|nil lnum The line number
---@return number|nil col The column number (defaults to 1)
local function parse_location(line)
  -- Match file.ext:line:col or file.ext:line (Unix-style)
  local file, lnum, col = line:match('([^%s]+%.%w+):(%d+):(%d+)')
  if file and lnum then return file, tonumber(lnum), tonumber(col) end

  file, lnum = line:match('([^%s]+%.%w+):(%d+)')
  if file and lnum then return file, tonumber(lnum), 1 end

  -- Match file.ext(line,col) format (TypeScript/MSBuild style)
  file, lnum, col = line:match('([^%s]+%.%w+)%((%d+),(%d+)%)')
  if file and lnum then return file, tonumber(lnum), tonumber(col) end

  return nil
end

--- Jump to the error location under cursor in the compilation buffer
--- Opens the file in a non-compilation window and positions cursor
local function jump_to_location()
  local line = vim.api.nvim_get_current_line()
  local file, lnum, col = parse_location(line)

  if not file then
    vim.notify('No file location found on this line', vim.log.levels.INFO, { title = NOTIFY_TITLE })
    return
  end

  -- Resolve relative paths to absolute using cwd
  local filepath = file
  if not vim.startswith(file, '/') then filepath = vim.fn.getcwd() .. '/' .. file end

  if not vim.uv.fs_stat(filepath) then
    vim.notify('File not found: ' .. file, vim.log.levels.WARN, { title = NOTIFY_TITLE })
    return
  end

  -- Find a suitable window (prefer non-special buffers, avoid compilation buffer)
  local target_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if buf ~= M.bufnr then
      local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf })
      if buftype == '' or buftype == nil then
        target_win = win
        break
      end
    end
  end

  if target_win then
    vim.api.nvim_set_current_win(target_win)
  else
    -- Fallback: jump to previous window
    vim.cmd('wincmd p')
  end

  vim.cmd('edit ' .. vim.fn.fnameescape(filepath))
  vim.api.nvim_win_set_cursor(0, { lnum, (col or 1) - 1 })
end

-------------------------------------------------------------------------------
-- Error Navigation (Emacs-style next-error / previous-error)
-------------------------------------------------------------------------------

--- Jump to the first error in the quickfix list
function M.first_error()
  local qf = vim.fn.getqflist()
  if #qf == 0 then
    vim.notify('No errors', vim.log.levels.INFO, { title = NOTIFY_TITLE })
    return
  end
  M.current_error_idx = 1
  vim.cmd('cfirst')
  vim.notify(string.format('Error 1 of %d', #qf), vim.log.levels.INFO, { title = NOTIFY_TITLE })
end

--- Jump to the last error in the quickfix list
function M.last_error()
  local qf = vim.fn.getqflist()
  if #qf == 0 then
    vim.notify('No errors', vim.log.levels.INFO, { title = NOTIFY_TITLE })
    return
  end
  M.current_error_idx = #qf
  vim.cmd('clast')
  vim.notify(string.format('Error %d of %d', #qf, #qf), vim.log.levels.INFO, { title = NOTIFY_TITLE })
end

--- Jump to the next error in the quickfix list
--- Wraps around to the first error if at the end
function M.next_error()
  local qf = vim.fn.getqflist()
  if #qf == 0 then
    vim.notify('No errors', vim.log.levels.INFO, { title = NOTIFY_TITLE })
    return
  end

  -- Get current quickfix index if we haven't tracked it
  if M.current_error_idx == 0 then M.current_error_idx = vim.fn.getqflist({ idx = 0 }).idx or 0 end

  if M.current_error_idx >= #qf then
    -- Wrap around to first error
    M.current_error_idx = 1
    vim.cmd('cfirst')
    vim.notify(string.format('Error 1 of %d (wrapped)', #qf), vim.log.levels.INFO, { title = NOTIFY_TITLE })
  else
    M.current_error_idx = M.current_error_idx + 1
    vim.cmd('cnext')
    vim.notify(string.format('Error %d of %d', M.current_error_idx, #qf), vim.log.levels.INFO, { title = NOTIFY_TITLE })
  end
end

--- Jump to the previous error in the quickfix list
--- Wraps around to the last error if at the beginning
function M.prev_error()
  local qf = vim.fn.getqflist()
  if #qf == 0 then
    vim.notify('No errors', vim.log.levels.INFO, { title = NOTIFY_TITLE })
    return
  end

  -- Get current quickfix index if we haven't tracked it
  if M.current_error_idx == 0 then M.current_error_idx = vim.fn.getqflist({ idx = 0 }).idx or 0 end

  if M.current_error_idx <= 1 then
    -- Wrap around to last error
    M.current_error_idx = #qf
    vim.cmd('clast')
    vim.notify(string.format('Error %d of %d (wrapped)', #qf, #qf), vim.log.levels.INFO, { title = NOTIFY_TITLE })
  else
    M.current_error_idx = M.current_error_idx - 1
    vim.cmd('cprev')
    vim.notify(string.format('Error %d of %d', M.current_error_idx, #qf), vim.log.levels.INFO, { title = NOTIFY_TITLE })
  end
end

--- Move cursor to next error line in compilation buffer (without jumping to file)
--- Similar to Emacs M-n in compilation mode
local function next_error_line()
  local line_count = vim.api.nvim_buf_line_count(0)
  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  for lnum = current_line + 1, line_count do
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
    if parse_location(line) then
      vim.api.nvim_win_set_cursor(0, { lnum, 0 })
      return
    end
  end
  vim.notify('No more errors below', vim.log.levels.INFO, { title = NOTIFY_TITLE })
end

--- Move cursor to previous error line in compilation buffer (without jumping to file)
--- Similar to Emacs M-p in compilation mode
local function prev_error_line()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  for lnum = current_line - 1, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
    if parse_location(line) then
      vim.api.nvim_win_set_cursor(0, { lnum, 0 })
      return
    end
  end
  vim.notify('No more errors above', vim.log.levels.INFO, { title = NOTIFY_TITLE })
end

-------------------------------------------------------------------------------
-- Buffer Syntax Highlighting
-------------------------------------------------------------------------------

--- Apply custom syntax rules to the compilation buffer
--- Highlights file paths, line numbers, error/warning keywords, and status info
---@param bufnr number The buffer number to apply syntax to
local function apply_buffer_syntax(bufnr)
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd('syntax clear')

    -- Header patterns (command info section)
    vim.cmd([[syntax match CompilationCommand /^Command: .*$/]])
    vim.cmd([[syntax match CompilationTimestamp /^\(Started\|Finished\): .*$/]])
    vim.cmd([[syntax match CompilationSeparator /^---$/]])

    -- Exit code patterns (contained within timestamp lines)
    vim.cmd([[syntax match CompilationSuccess /(exit code: 0)/ contained containedin=CompilationTimestamp]])
    vim.cmd([[syntax match CompilationError /(exit code: [1-9][0-9]*)/ contained containedin=CompilationTimestamp]])

    -- Error/warning keywords (case insensitive, must be followed by : or space)
    vim.cmd([[syntax match CompilationErrorMsg /\c\<error\>\ze[: ]/]])
    vim.cmd([[syntax match CompilationWarningMsg /\c\<warning\>\ze[: ]/]])
    vim.cmd([[syntax match CompilationNote /\c\<note\>\ze[: ]/]])
    vim.cmd([[syntax match CompilationInfo /\c\<info\>\ze[: ]/]])

    -- File paths with line numbers: file.rs:10:5 or file.ts(10,5)
    vim.cmd([[syntax match CompilationFilePath /[^ ]\+\.[a-zA-Z0-9_]\+\ze[:(]/ nextgroup=CompilationLocation]])
    vim.cmd(
      [[syntax match CompilationLocation /:\d\+\(:\d\+\)\?/ contained contains=CompilationLineNr,CompilationColNr]]
    )
    vim.cmd([[syntax match CompilationLocation /(\d\+,\d\+)/ contained contains=CompilationLineNr,CompilationColNr]])
    vim.cmd([[syntax match CompilationLineNr /\d\+/ contained]])
  end)
end

-------------------------------------------------------------------------------
-- Buffer Management
-------------------------------------------------------------------------------

--- Get or create the compilation output buffer
--- Sets up buffer options, keymaps, and syntax highlighting
---@return number bufnr The buffer number
local function get_buffer()
  -- Reuse existing buffer if valid
  if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then return M.bufnr end

  ensure_highlights()

  -- Create scratch buffer (unlisted, scratch)
  M.bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(M.bufnr, config.buffer_name)
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = M.bufnr })
  vim.api.nvim_set_option_value('modifiable', true, { buf = M.bufnr })
  vim.api.nvim_set_option_value('filetype', 'compilation', { buf = M.bufnr })

  apply_buffer_syntax(M.bufnr)

  -- Buffer-local keymaps for navigation and control
  local opts = { buffer = M.bufnr, silent = true }
  vim.keymap.set('n', 'q', '<cmd>CompileStop<CR>', opts) -- Stop Compilation
  vim.keymap.set('n', 'R', '<cmd>Recompile<CR>', opts) -- Re-run last command
  vim.keymap.set('n', '<CR>', jump_to_location, opts) -- Jump to error
  vim.keymap.set('n', 'gf', jump_to_location, opts) -- Jump to error (gf style)
  vim.keymap.set('n', 'Q', '<cmd>copen<CR>', opts) -- Open quickfix list
  vim.keymap.set('n', ']e', next_error_line, opts) -- Next error line (no jump)
  vim.keymap.set('n', '[e', prev_error_line, opts) -- Prev error line (no jump)
  vim.keymap.set('n', ']q', M.next_error, { desc = 'Next [Q]uickfix error' })
  vim.keymap.set('n', '[q', M.prev_error, { desc = 'Prev [Q]uickfix error' })
  vim.keymap.set('n', ']Q', M.last_error, { desc = 'Last [Q]uickfix error' })
  vim.keymap.set('n', '[Q', M.first_error, { desc = 'First [Q]uickfix error' })

  return M.bufnr
end

--- Open the compilation window, or return existing window if already open
---@return number win The window handle
local function open_window()
  local buf = get_buffer()

  -- Check if buffer is already displayed in a window
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then return win end
  end

  -- Create new split window for compilation output
  vim.cmd(string.format('%s %dsplit', config.split_direction, config.split_size))
  vim.api.nvim_win_set_buf(0, buf)
  local win = vim.api.nvim_get_current_win()
  vim.cmd('wincmd p') -- Return focus to previous window
  vim.api.nvim_set_option_value('winfixheight', true, { win = win })

  return win
end

-------------------------------------------------------------------------------
-- Output Processing
-------------------------------------------------------------------------------

--- Remove ANSI escape sequences from output lines
--- Handles colors, cursor control, OSC sequences, and other terminal codes
---@param data string[] Array of output lines
---@return string[] clean Array of cleaned lines (empty lines filtered out)
local function strip_ansi(data)
  local clean = {}
  for _, line in ipairs(data) do
    if line ~= '' then
      local clean_line = line
        :gsub('\27%[[0-9;?]*[A-Za-z]', '') -- CSI sequences (colors, cursor, etc.)
        :gsub('\27%][^\a]*\a', '') -- OSC sequences (window title, etc.)
        :gsub('\27[()][AB012]', '') -- Character set selection
        :gsub('\27=', '') -- Application keypad mode
        :gsub('\27>', '') -- Normal keypad mode
        :gsub('\r', '') -- Carriage returns
      table.insert(clean, clean_line)
    end
  end
  return clean
end

--- Append command output to the compilation buffer
--- Strips ANSI codes and auto-scrolls if enabled
---@param buf number Buffer number
---@param win number|nil Window handle (for auto-scroll)
---@param data string[]|nil Output lines to append
local function append_output(buf, win, data)
  if not data then return end
  local clean = strip_ansi(data)
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(buf) then return end
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, clean)

    -- Auto-scroll to bottom (only if user is not in the compilation window)
    if config.auto_scroll and win and vim.api.nvim_win_is_valid(win) then
      local current_win = vim.api.nvim_get_current_win()
      if current_win ~= win then vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 }) end
    end
  end)
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

--- Toggle visibility of the compilation buffer window
--- Opens it if closed, closes it if open
function M.toggle()
  if not M.bufnr or not vim.api.nvim_buf_is_valid(M.bufnr) then
    vim.notify('No compilation buffer exists', vim.log.levels.INFO, { title = NOTIFY_TITLE })
    return
  end

  -- Check if buffer is visible in any window; if so, close it
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == M.bufnr then
      vim.api.nvim_win_close(win, true)
      return
    end
  end

  -- Buffer exists but not visible - show it
  open_window()
end

--- Stop the currently running compilation job
function M.stop()
  if M.job_id then
    vim.fn.jobstop(M.job_id)
    M.job_id = nil
    vim.notify('Compilation stopped', vim.log.levels.WARN, { title = NOTIFY_TITLE })
  else
    vim.notify('No compilation running', vim.log.levels.INFO, { title = NOTIFY_TITLE })
  end
end

--- Re-run the last compilation command
function M.recompile()
  if M.last_command then
    M.compile('')
  else
    vim.notify('No previous compilation', vim.log.levels.WARN, { title = NOTIFY_TITLE })
  end
end

--- Run a compilation command asynchronously
--- Command priority: args > detected project command > last command > makeprg
---@param args string Command to run (empty string to use auto-detection)
function M.compile(args)
  -- Stop any existing compilation
  if M.job_id then
    vim.fn.jobstop(M.job_id)
    M.job_id = nil
  end

  -- Determine command to run (priority: explicit > detected > last > makeprg)
  local detector = get_detector()
  local command = (args ~= '' and args) or (detector and detector.cmd) or M.last_command or vim.o.makeprg

  -- Determine language for error format selection
  local lang = detector and detector.lang or vim.bo.filetype
  M.last_command = command

  local buf = get_buffer()
  local win = open_window()

  -- Handle buffer clearing or appending
  local start_line = 0
  if not config.clear_on_compile then
    start_line = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_buf_set_lines(buf, start_line, start_line, false, { '', '---' })
    start_line = start_line + 2
  end

  -- Write header with command and timestamp
  vim.api.nvim_buf_set_lines(
    buf,
    config.clear_on_compile and 0 or start_line,
    config.clear_on_compile and -1 or start_line,
    false,
    {
      'Command: ' .. command,
      'Started: ' .. os.date('%H:%M:%S'),
      '',
    }
  )

  -- Start async job with shell execution
  M.job_id = vim.fn.jobstart({ 'sh', '-c', command }, {
    on_stdout = function(_, data) append_output(buf, win, data) end,
    on_stderr = function(_, data) append_output(buf, win, data) end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        -- Parse output with language-specific errorformat into quickfix list
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local efm = efm_map[lang] or vim.o.errorformat
        local qf_items = vim.fn.getqflist({
          lines = lines,
          efm = efm,
        }).items or {}

        -- Filter to only valid entries (those with recognized file:line patterns)
        local valid_items = {}
        for _, item in ipairs(qf_items) do
          if item.valid == 1 then table.insert(valid_items, item) end
        end

        -- Populate quickfix list with parsed errors
        vim.fn.setqflist({}, ' ', {
          title = 'Compilation: ' .. command,
          items = valid_items,
        })

        -- Write footer with completion status
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
          '',
          string.format('Finished: %s (exit code: %d)', os.date('%H:%M:%S'), exit_code),
        })

        M.job_id = nil

        -- Notify user and handle window based on success/failure
        if exit_code ~= 0 then
          vim.notify('Compilation Failed (exit ' .. exit_code .. ')', vim.log.levels.ERROR, { title = NOTIFY_TITLE })
        else
          vim.notify('Compilation Success', vim.log.levels.INFO, { title = NOTIFY_TITLE })
          vim.cmd('cclose') -- Close quickfix on success (no errors to show)
          if config.auto_close_on_success then
            if win and vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
          end
        end
      end)
    end,
  })

  if not M.job_id then vim.notify('Failed to start compilation', vim.log.levels.ERROR, { title = NOTIFY_TITLE }) end
end

-------------------------------------------------------------------------------
-- User Commands
-------------------------------------------------------------------------------

-- :Compile [cmd] - Run compilation (auto-detect if no command given)
vim.api.nvim_create_user_command('Compile', function(opts) M.compile(opts.args) end, {
  nargs = '?',
  complete = 'shellcmd',
})

-- :CompileStop - Stop the running compilation job
vim.api.nvim_create_user_command('CompileStop', function() M.stop() end, {})

-- :CompileToggle - Show/hide the compilation window
vim.api.nvim_create_user_command('CompileToggle', function() M.toggle() end, {})

-- :Recompile - Re-run the last compilation command
vim.api.nvim_create_user_command('Recompile', function() M.recompile() end, {})

return M
