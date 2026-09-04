---Helpers shared by the VCS backends for running commands and reporting output.
local M = {}

---Run a command asynchronously and invoke `cb` with its result on the main loop.
---@param cmd string[]
---@param root string? repository root used as the command cwd (nil: inherit)
---@param cb fun(res: vim.SystemCompleted)
function M.run(cmd, root, cb)
  vim.system(cmd, { text = true, cwd = root }, function(res)
    vim.schedule(function()
      if not res then
        cb({ code = -1, stderr = 'failed to start command', stdout = '' })
        return
      end
      cb(res)
    end)
  end)
end

---Notify the user about a finished command; returns true on success.
---@param res vim.SystemCompleted
---@param ok_msg string?
---@return boolean
function M.report(res, ok_msg)
  if res.code == 0 then
    if ok_msg then vim.notify(ok_msg, vim.log.levels.INFO, { title = 'VCS' }) end
    return true
  end
  local detail = vim.trim(res.stderr ~= '' and res.stderr or (res.stdout or ''))
  if detail == '' then detail = ('exit code %s'):format(res.code) end
  vim.notify(detail, vim.log.levels.ERROR, { title = 'VCS' })
  return false
end

return M
