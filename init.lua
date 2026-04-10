require('config.deps')
require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.lsp')

local function require_directory(path)
  local files = vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/" .. path)
  for _, file in ipairs(files) do
    local plugin_name, _ = file:gsub('.lua', '')
    require(path .. "." .. plugin_name)
  end
end

require_directory("plugins")
require("util.compile")
require("util.gitu")
