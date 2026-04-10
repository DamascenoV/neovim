---@module "diff_signs"
---@description Open gitu in a tmux split

local M = {}

--- Get the git toplevel for a file path
---@param filepath string
---@return string|nil
local function git_root(filepath)
  local dir = vim.fn.fnamemodify(filepath, ":h")
  local out = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })
  if vim.v.shell_error ~= 0 then return nil end
  return out[1]
end

--- Open gitu in a tmux split, or switch to existing gitu pane
function M.gitu()
  if not vim.env.TMUX then
    vim.notify("Not in a tmux session", vim.log.levels.WARN)
    return
  end

  -- Check if gitu is already running in this session
  local panes = vim.fn.systemlist({ "tmux", "list-panes", "-s", "-F", "#{pane_id} #{pane_current_command}" })
  for _, line in ipairs(panes) do
    local pane_id, cmd = line:match("^(%S+)%s+(%S+)")
    if cmd == "gitu" then
      vim.fn.system({ "tmux", "select-pane", "-t", pane_id })
      return
    end
  end

  local root = git_root(vim.api.nvim_buf_get_name(0)) or vim.fn.getcwd()
  vim.fn.system({ "tmux", "split-window", "-v", "-b", "-f", "-p", "50", "-c", root, "gitu" })
end

vim.keymap.set("n", "<leader>gg", M.gitu, { silent = true, desc = "Open [g]itu" })

return M
