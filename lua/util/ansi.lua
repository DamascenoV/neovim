-- ANSI SGR -> clean text + highlight spans.
-- Parses 256-color / truecolor foreground sequences into dynamically created
-- highlight groups, so buffers can show the *native* palette of external
-- tools (git, jj) instead of a hand-rolled regex approximation.
local api = vim.api

local M = {}

local BASE16 = {
  '#1d2023', --  0 black
  '#c15959', --  1 red
  '#37ad82', --  2 green
  '#fac03b', --  3 yellow
  '#7398dd', --  4 blue
  '#ca70d6', --  5 purple
  '#a3db81', --  6 cyan
  '#d1d1d1', --  7 white
  '#5c6366', --  8 bright black (dim)
  '#ff6b6b', --  9 bright red
  '#5fd7a0', -- 10 bright green
  '#ffd580', -- 11 bright yellow
  '#89a7e8', -- 12 bright blue
  '#d98ae6', -- 13 bright purple
  '#b3e8c9', -- 14 bright cyan
  '#ffffff', -- 15 bright white
}
local CUBE = { 0, 95, 135, 175, 215, 255 }

---@param idx integer xterm-256 palette index
---@return string hex color
local function xterm256(idx)
  if idx < 16 then
    return BASE16[idx + 1]
  elseif idx < 232 then
    local i = idx - 16
    return ('#%02x%02x%02x'):format(CUBE[math.floor(i / 36) + 1], CUBE[math.floor((i % 36) / 6) + 1], CUBE[(i % 6) + 1])
  end
  local v = 8 + (idx - 232) * 10
  return ('#%02x%02x%02x'):format(v, v, v)
end

local defined = {} ---@type table<string, boolean>

---@param fg string hex color
---@param bold boolean?
---@return string highlight group name
local function hl_name(fg, bold)
  local name = ('UtilAnsi_%s%s'):format(fg:gsub('#', ''), bold and 'b' or '')
  if not defined[name] then
    pcall(api.nvim_set_hl, 0, name, { fg = fg, bold = bold or nil })
    defined[name] = true
  end
  return name
end

--- Parse ANSI-colored `text` into plain lines plus per-line highlight spans.
---@param text string raw output containing SGR sequences
---@return string[] lines
---@return table spans -- 1-based line -> list of { start0, end0, group } (0-based byte columns)
function M.parse(text)
  local lines, spans = {}, {}
  local fg, bold, dim ---@type string?, boolean?, boolean?
  for raw in (text .. '\n'):gmatch('(.-)\n') do
    local parts, col, line_spans = {}, 0, nil
    local pos = 1
    while pos <= #raw do
      local s, e = raw:find('\27%[[%d;]*m', pos)
      if not s then
        local tail = raw:sub(pos)
        if #tail > 0 and (fg or dim) then
          line_spans = line_spans or {}
          line_spans[#line_spans + 1] = { col, col + #tail, hl_name(dim and BASE16[9] or fg, bold) }
        end
        parts[#parts + 1] = tail
        break
      end
      local chunk = raw:sub(pos, s - 1)
      if #chunk > 0 then
        if fg or dim then
          line_spans = line_spans or {}
          line_spans[#line_spans + 1] = { col, col + #chunk, hl_name(dim and BASE16[9] or fg, bold) }
        end
        parts[#parts + 1] = chunk
        col = col + #chunk
      end
      local nums = {}
      for n in raw:sub(s + 2, e - 1):gmatch('%d+') do
        nums[#nums + 1] = tonumber(n)
      end
      if #nums == 0 then nums = { 0 } end -- bare ESC[m is a reset
      local i = 1
      while i <= #nums do
        local n = nums[i]
        if n == 0 then
          fg, bold, dim = nil, false, false
        elseif n == 1 then
          bold = true
        elseif n == 2 then
          dim = true
        elseif n == 22 then
          bold, dim = false, false
        elseif n >= 30 and n <= 37 then
          fg = BASE16[n - 29]
        elseif n == 39 then
          fg = nil
        elseif n >= 90 and n <= 97 then
          fg = BASE16[n - 81]
        elseif n == 38 and nums[i + 1] == 5 then
          fg = xterm256(nums[i + 2] or 0)
          i = i + 2
        elseif n == 38 and nums[i + 1] == 2 then
          fg = ('#%02x%02x%02x'):format(nums[i + 2] or 0, nums[i + 3] or 0, nums[i + 4] or 0)
          i = i + 4
        end
        i = i + 1
      end
      pos = e + 1
    end
    lines[#lines + 1] = table.concat(parts)
    if line_spans then spans[#lines] = line_spans end
  end
  return lines, spans
end

--- Apply parsed `spans` to `buf` in namespace `ns`.
---@param buf integer
---@param ns integer
---@param spans table -- as returned by M.parse
function M.apply(buf, ns, spans)
  for lnum, list in pairs(spans) do
    for _, sp in ipairs(list) do
      pcall(api.nvim_buf_set_extmark, buf, ns, lnum - 1, sp[1], {
        end_col = sp[2],
        hl_group = sp[3],
        priority = 60,
      })
    end
  end
end

return M
