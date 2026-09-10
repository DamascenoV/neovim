local api = vim.api

local M = {}

--- Default height for utility bottom splits (same ratio the mini config used).
function M.list_height() return math.max(math.floor(vim.o.lines / 5) + 2, 8) end

function M.escape_statusline(value) return value:gsub('%%', '%%%%') end

--- Open a full-width bottom split showing `bufnr` and focus it.
---@param bufnr integer
---@param opts {height: integer?, win: integer?}
---@return integer? winnr
function M.open_bottom(bufnr, opts)
  opts = opts or {}
  local height = opts.height or M.list_height()
  local anchor = opts.win or -1

  local ok, winnr = pcall(api.nvim_open_win, bufnr, true, {
    split = 'below',
    win = anchor,
    height = height,
  })
  if ok and winnr and winnr ~= 0 then return winnr end

  if anchor ~= -1 and api.nvim_win_is_valid(anchor) then pcall(api.nvim_set_current_win, anchor) end
  local ok2, err = pcall(api.nvim_command, ('botright %dsplit'):format(height))
  if not ok2 then
    vim.notify(('Unable to open bottom split: %s'):format(err), vim.log.levels.WARN)
    return
  end

  winnr = api.nvim_get_current_win()
  api.nvim_win_set_buf(winnr, bufnr)
  return winnr
end

return M
