local api = vim.api
local M = {}
local drafts = {}

---A multiline draft. Failed submissions stay editable and can be retried.
function M.open(opts)
  local existing = drafts[opts.root]
  if existing and api.nvim_buf_is_valid(existing) then
    local existing_win = vim.fn.bufwinid(existing)
    if existing_win == -1 then existing_win = require('util.win').open_bottom(existing, { height = 12 }) end
    if existing_win then api.nvim_set_current_win(existing_win) end
    return existing, existing_win
  end
  local buf = api.nvim_create_buf(false, true)
  local win = require('util.win').open_bottom(buf, { height = 12 })
  if not win then
    api.nvim_buf_delete(buf, { force = true })
    return
  end
  drafts[opts.root] = buf
  vim.bo[buf].buftype = 'acwrite'
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = 'gitcommit'
  api.nvim_buf_set_name(buf, ('vcs-message://%d/%s'):format(buf, opts.title))
  api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(opts.text or '', '\n', { plain = true }))
  vim.bo[buf].modified = false
  vim.wo[win].winbar = require('util.win').escape_statusline(' ' .. opts.title .. ' · :w / <C-s> submit · q cancel ')
  local saving = false
  local function dispose()
    for _, draft_win in ipairs(vim.fn.win_findbuf(buf)) do
      pcall(api.nvim_win_close, draft_win, true)
    end
    if api.nvim_buf_is_valid(buf) then api.nvim_buf_delete(buf, { force = true }) end
    drafts[opts.root] = nil
  end
  local function submit()
    if saving then return end
    local text = table.concat(api.nvim_buf_get_lines(buf, 0, -1, false), '\n')
    if vim.trim(text) == '' then
      vim.notify('Message cannot be empty', vim.log.levels.WARN)
      return
    end
    saving = true
    vim.bo[buf].modifiable = false
    opts.submit(text, function(ok)
      saving = false
      if not api.nvim_buf_is_valid(buf) then return end
      vim.bo[buf].modifiable = true
      if ok then dispose() end
    end)
  end
  api.nvim_create_autocmd('BufWriteCmd', { buffer = buf, callback = submit })
  vim.keymap.set({ 'n', 'i' }, '<C-s>', submit, { buffer = buf, desc = 'Submit message' })
  vim.keymap.set('n', 'q', function()
    if saving then return end
    if vim.bo[buf].modified and vim.fn.confirm('Discard this message draft?', '&Discard\n&Keep', 2) ~= 1 then return end
    dispose()
  end, { buffer = buf, desc = 'Cancel message' })
  return buf, win
end

return M
