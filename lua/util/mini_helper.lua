local M = {}

local function get_permissions(path)
  local stat = vim.loop.fs_stat(path)
  if not stat then return "----------" end

  local mode = stat.mode
  local perms = ""

  if stat.type == "directory" then
    perms = "d"
  elseif stat.type == "link" then
    perms = "l"
  else
    perms = "-"
  end

  perms = perms .. (math.floor(mode / 256) % 2 == 1 and "r" or "-") -- 0x100
  perms = perms .. (math.floor(mode / 128) % 2 == 1 and "w" or "-") -- 0x080
  perms = perms .. (math.floor(mode / 64) % 2 == 1 and "x" or "-")  -- 0x040

  perms = perms .. (math.floor(mode / 32) % 2 == 1 and "r" or "-")  -- 0x020
  perms = perms .. (math.floor(mode / 16) % 2 == 1 and "w" or "-")  -- 0x010
  perms = perms .. (math.floor(mode / 8) % 2 == 1 and "x" or "-")   -- 0x008

  perms = perms .. (math.floor(mode / 4) % 2 == 1 and "r" or "-")   -- 0x004
  perms = perms .. (math.floor(mode / 2) % 2 == 1 and "w" or "-")   -- 0x002
  perms = perms .. (mode % 2 == 1 and "x" or "-")                   -- 0x001

  return perms
end

local function format_size(size)
  if size < 1024 then
    return string.format("%4d", size)
  elseif size < 1024 * 1024 then
    return string.format("%3.1fK", size / 1024)
  elseif size < 1024 * 1024 * 1024 then
    return string.format("%3.1fM", size / (1024 * 1024))
  else
    return string.format("%3.1fG", size / (1024 * 1024 * 1024))
  end
end

local function format_mtime(mtime_sec)
  if not mtime_sec then return "           " end

  local current_time = os.time()
  local time_diff = current_time - mtime_sec

  if time_diff < 6 * 30 * 24 * 60 * 60 then
    return os.date("%b %d %H:%M", mtime_sec)
  else
    return os.date("%b %d  %Y", mtime_sec)
  end
end

local function ls_prefix(fs_entry)
  local path = fs_entry.path

  local stat = vim.loop.fs_stat(path)
  if not stat then
    return ""
  end

  local permissions = get_permissions(path)
  local size = format_size(stat.size or 0)
  local mtime = format_mtime(stat.mtime and stat.mtime.sec)

  return string.format("%s %8s %s ", permissions, size, mtime)
end

M.win_config = function()
  local height = math.floor(vim.o.lines / 4)
  local width = math.floor(vim.o.columns)
  return {
    height = height,
    width = width,
  }
end

M.ls_prefix = ls_prefix
M.get_permissions = get_permissions
M.format_size = format_size
M.format_mtime = format_mtime

return M
