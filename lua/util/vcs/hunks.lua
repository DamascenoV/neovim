local M = {}

---Keep Git's patch headers/quoting intact; only split at unified hunk headers.
function M.parse(raw)
  local header, hunks, current = {}, {}, nil
  local lines = vim.split(raw, '\n', { plain = true })
  if lines[#lines] == '' then table.remove(lines) end
  for _, line in ipairs(lines) do
    if line:match('^@@ %-') then
      current = { lines = { line } }
      hunks[#hunks + 1] = current
    elseif current then
      current.lines[#current.lines + 1] = line
    else
      header[#header + 1] = line
    end
  end
  for _, hunk in ipairs(hunks) do
    hunk.patch = table.concat(header, '\n') .. '\n' .. table.concat(hunk.lines, '\n') .. '\n'
  end
  return hunks
end

return M
