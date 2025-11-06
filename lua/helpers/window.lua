local M = {}


M.win_config = function()
  local height = math.floor(vim.o.lines / 7)
  local width = math.floor(vim.o.columns)
  return {
    anchor = 'NW', height = height, width = width,
    row = math.floor(vim.o.lines - height),
    col = math.floor(0.5 * (vim.o.columns - width)),
  }
end

return M
