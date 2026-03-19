local M = {}

local HOVER_METHOD = 'textDocument/hover'
local LSPLIT_AUGROUP = 'LSPlit'
local LSPLIT_BUF_NAME = 'lsplit'
local LSPLIT_CONCEALLEVEL = 3
local LSPLIT_NORMAL_HL = 'LSPlitNormal'
local LSPLIT_BG = '#131515'

M.hover_bufnr = nil ---@type integer|nil
M.hover_winid = nil ---@type integer|nil
M.orig_winid = nil ---@type integer|nil
M.orig_bufnr = nil ---@type integer|nil
M.orig_pos = nil ---@type integer[]|nil
M.remain_focused = true ---@type boolean

M.lsp_request_cancel_fn = nil ---@type function|nil
M.hover_augroup = nil ---@type integer|nil

local function has_nvim_0_11()
  return vim.fn.has('nvim-0.11') == 1
end

local function is_valid_buf(bufnr)
  return bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr)
end

local function is_valid_win(winid)
  return winid ~= nil and vim.api.nvim_win_is_valid(winid)
end

local function cancel_hover_request()
  if not M.lsp_request_cancel_fn then
    return
  end

  M.lsp_request_cancel_fn()
  M.lsp_request_cancel_fn = nil
end

local function reset_hover_state()
  M.hover_bufnr = nil
  M.hover_winid = nil
  M.orig_winid = nil
  M.orig_bufnr = nil
  M.orig_pos = nil
  M.remain_focused = true
  M.hover_augroup = nil
end

local function set_hover_lines(lines)
  if not is_valid_buf(M.hover_bufnr) then
    return
  end

  vim.bo[M.hover_bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(M.hover_bufnr, 0, -1, false, lines)
  vim.bo[M.hover_bufnr].modifiable = false
end

local function get_hover_context(source_winid)
  local winid = source_winid or vim.api.nvim_get_current_win()
  if not is_valid_win(winid) then
    return nil
  end

  local bufnr = vim.api.nvim_win_get_buf(winid)
  local cursor_pos = vim.api.nvim_win_get_cursor(winid)
  local row, col = cursor_pos[1], cursor_pos[2]
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local current_line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ''

  if row < 1 or row > line_count or col < 0 or col > #current_line then
    vim.notify('Invalid cursor position detected. Skipping hover content update.', vim.log.levels.WARN)
    return nil
  end

  return {
    bufnr = bufnr,
    winid = winid,
  }
end

local function set_hover_buffer_keymaps(bufnr)
  vim.keymap.set('n', 'q', M.close_hover_split, {
    noremap = true,
    silent = true,
    buffer = bufnr,
  })
end

local function restore_original_cursor()
  if M.remain_focused or not M.orig_pos then
    return
  end
  if not is_valid_win(M.orig_winid) then
    M.orig_winid = nil
    return
  end

  vim.api.nvim_win_set_cursor(M.orig_winid, M.orig_pos)
end

local function setup_hover_buffer(bufnr)
  vim.api.nvim_buf_set_name(bufnr, LSPLIT_BUF_NAME)
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].buftype = 'nowrite'
  vim.bo[bufnr].filetype = 'markdown'
  vim.b[bufnr].is_lsp_hover_split = true
end

local function setup_hover_window(winid)
  local normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  vim.api.nvim_set_hl(0, LSPLIT_NORMAL_HL, {
    fg = normal_hl.fg,
    bg = LSPLIT_BG,
  })

  vim.wo[winid].wrap = true
  vim.wo[winid].conceallevel = LSPLIT_CONCEALLEVEL
  vim.wo[winid].winhighlight = ('Normal:%s,EndOfBuffer:%s'):format(LSPLIT_NORMAL_HL, LSPLIT_NORMAL_HL)
end

local function create_hover_autocmds()
  M.hover_augroup = vim.api.nvim_create_augroup(LSPLIT_AUGROUP, { clear = true })

  vim.api.nvim_create_autocmd('BufEnter', {
    group = M.hover_augroup,
    callback = function(ev)
      if ev.buf == M.hover_bufnr then
        set_hover_buffer_keymaps(ev.buf)
        return
      end

      if ev.buf == M.orig_bufnr then
        restore_original_cursor()
      end
    end,
  })

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'LspProgress' }, {
    group = M.hover_augroup,
    callback = function(args)
      if not (is_valid_buf(M.hover_bufnr) and is_valid_win(M.hover_winid)) then
        return true
      end
      if args.buf ~= M.hover_bufnr and M.check_hover_support(args.buf) then
        M.update_hover_content()
      end
    end,
  })

  vim.api.nvim_create_autocmd({ 'BufWipeout', 'BufDelete' }, {
    group = M.hover_augroup,
    callback = function(args)
      if args.buf == M.hover_bufnr then
        vim.schedule(M.close_hover_split)
        return true
      end
    end,
  })
end

---@param bufnr? integer
---@return boolean
function M.check_hover_support(bufnr)
  if has_nvim_0_11() then
    vim.validate('bufnr', bufnr, 'number', true)
  else
    vim.validate({ bufnr = { bufnr, { 'number', 'nil' } } })
  end

  local target_bufnr = bufnr or vim.api.nvim_get_current_buf()
  if target_bufnr == M.hover_bufnr then
    return false
  end

  local clients = vim.lsp.get_clients({ bufnr = target_bufnr, method = HOVER_METHOD })
  return not vim.tbl_isempty(clients)
end

---@param source_winid? integer
function M.update_hover_content(source_winid)
  if not (is_valid_buf(M.hover_bufnr) and is_valid_win(M.hover_winid)) then
    return
  end

  cancel_hover_request()

  local context = get_hover_context(source_winid)
  if not context or context.bufnr == M.hover_bufnr then
    return
  end

  _, M.lsp_request_cancel_fn = vim.lsp.buf_request(
    context.bufnr,
    HOVER_METHOD,
    vim.lsp.util.make_position_params(context.winid, 'utf-16'),
    function(err, result)
      M.lsp_request_cancel_fn = nil
      if err or not (result and result.contents) or not is_valid_buf(M.hover_bufnr) then
        return
      end

      local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
      set_hover_lines(lines)
    end
  )
end

---@param opts? { remain_focused?: boolean }
function M.create_hover_split(opts)
  if is_valid_win(M.hover_winid) then
    M.close_hover_split()
    return
  end

  opts = opts or {}
  M.remain_focused = opts.remain_focused ~= false
  M.orig_bufnr = vim.api.nvim_get_current_buf()
  M.orig_winid = vim.api.nvim_get_current_win()
  M.orig_pos = vim.api.nvim_win_get_cursor(M.orig_winid)
  M.hover_bufnr = vim.api.nvim_create_buf(false, true)

  local win_opts = {
    focusable = true,
    vertical = false,
    style = 'minimal',
    split = 'below',
    height = math.floor(vim.o.lines / 7) + 3,
  }

  create_hover_autocmds()
  M.hover_winid = vim.api.nvim_open_win(M.hover_bufnr, not M.remain_focused, win_opts)

  setup_hover_buffer(M.hover_bufnr)
  setup_hover_window(M.hover_winid)
  M.update_hover_content(M.orig_winid)
end

function M.split()
  M.create_hover_split({ remain_focused = true })
end

function M.close_hover_split()
  cancel_hover_request()

  if is_valid_buf(M.hover_bufnr) then
    vim.api.nvim_buf_delete(M.hover_bufnr, { force = true })
  end

  reset_hover_state()
end

return M
