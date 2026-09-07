local M = {}

---Prefer the current file's repository; unnamed/utility buffers use cwd.
function M.root(marker, cwd)
  if cwd then return vim.fs.root(vim.fn.fnamemodify(cwd, ':p'), marker) end
  local name = vim.api.nvim_buf_get_name(0)
  if vim.bo.buftype == '' and name ~= '' then
    local scope = vim.fs.root(name, { '.git', '.jj' })
    if scope then
      local root = vim.fs.root(name, marker)
      return root == scope and root or nil
    end
  end
  local scope = vim.fs.root(vim.fn.getcwd(), { '.git', '.jj' })
  local root = vim.fs.root(vim.fn.getcwd(), marker)
  return root == scope and root or nil
end

function M.project(cwd)
  if cwd then return vim.fn.fnamemodify(cwd, ':p') end
  return M.root({ '.git', '.jj' }) or vim.fn.getcwd()
end

return M
