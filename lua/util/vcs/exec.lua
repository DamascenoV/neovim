---Helpers shared by the VCS backends for running commands and reporting output.
local M = {}
M.busy = {}
M.errors = {}

---Run a command asynchronously and invoke `cb` with its result on the main loop.
---@param cmd string[]
---@param root string? repository root used as the command cwd (nil: inherit)
---@param cb fun(res: vim.SystemCompleted)
function M.run(cmd, root, cb, opts)
  local settings = vim.tbl_extend('force', { text = true, cwd = root }, opts or {})
  local ok, job = pcall(vim.system, cmd, settings, function(res)
    vim.schedule(function()
      if not res then
        cb({ code = -1, stderr = 'failed to start command', stdout = '' })
        return
      end
      cb(res)
    end)
  end)
  if not ok then vim.schedule(function() cb({ code = -1, stdout = '', stderr = tostring(job) }) end) end
  return ok and job or nil
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
  local detail = vim.trim(res.stderr and res.stderr ~= '' and res.stderr or (res.stdout or ''))
  if detail == '' then detail = ('exit code %s'):format(res.code) end
  M.errors[#M.errors + 1] = os.date('%H:%M:%S') .. ' · ' .. detail
  if #M.errors > 20 then table.remove(M.errors, 1) end
  vim.notify(detail, vim.log.levels.ERROR, { title = 'VCS' })
  return false
end

return M
