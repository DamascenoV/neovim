local M = {}

M.win_config = function()
  local height = math.floor(vim.o.lines / 4)
  local width = math.floor(vim.o.columns)
  return {
    anchor = 'NW', height = height, width = width,
    row = math.floor(vim.o.lines),
    col = math.floor(0.5 * (vim.o.columns - width)),
    zindex = 200
  }
end

M.notify_config = function ()
  return {
    anchor = 'NW',
    row = math.floor(vim.o.lines),
  }
end

return M
