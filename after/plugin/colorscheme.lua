-- local status, gruvbox = pcall(require, 'gruvbox')
-- if not status then return end
--
-- gruvbox.setup({
--   palette_overrides = {
--     bright_yellow = '#f8fe7a',
--     bright_green = '#698b69',
--     bright_blue = '#f2e5bc',
--     bright_orange = '#8e6fbd',
--     bright_red = '#cc6666',
--     bright_purple = '#fb4934',
--     neutral_yellow = '#f8fe7a',
--   },
--   overrides = {
--   },
--   transparent_mode = true,
-- })
-- vim.cmd("colorscheme gruvbox")

local status, colorbuddy = pcall(require, 'colorbuddy')
if not status then return end

colorbuddy.colorscheme('gruvbuddy')
require("colorizer").setup()

local c = require("colorbuddy.color").colors
local Group = require("colorbuddy.group").Group
local g = require("colorbuddy.group").groups
local s = require("colorbuddy.style").styles

Group.new("@variable", c.superwhite, nil)
Group.new("GoTestSuccess", c.green, nil, s.bold)
Group.new("GoTestFail", c.red, nil, s.bold)
-- Group.new('Keyword', c.purple, nil, nil)
Group.new("TSPunctBracket", c.orange:light():light())
Group.new("StatuslineError1", c.red:light():light(), g.Statusline)
Group.new("StatuslineError2", c.red:light(), g.Statusline)
Group.new("StatuslineError3", c.red, g.Statusline)
Group.new("StatuslineError3", c.red:dark(), g.Statusline)
Group.new("StatuslineError3", c.red:dark():dark(), g.Statusline)
Group.new("pythonTSType", c.red)
Group.new("goTSType", g.Type.fg:dark(), nil, g.Type)
Group.new("typescriptTSConstructor", g.pythonTSType)
Group.new("typescriptTSProperty", c.blue)
Group.new("WinSeparator", nil, nil)
-- Group.new("LspReferenceText", nil, c.gray0:light(), s.bold)
-- Group.new("LspReferenceWrite", nil, c.gray0:light())
-- Group.new("TSKeyword", c.purple, nil, s.underline, c.blue)
-- Group.new("LuaFunctionCall", c.green, nil, s.underline + s.nocombine, g.TSKeyword.guisp)
Group.new("TSTitle", c.blue)
Group.new("InjectedLanguage", nil, g.Normal.bg:dark())
Group.new("LspParameter", nil, nil, s.italic)
Group.new("LspDeprecated", nil, nil, s.strikethrough)
Group.new("@function.bracket", g.Normal, g.Normal)

vim.cmd [[
highlight link @function.call.lua LuaFunctionCall
hi! Normal ctermbg=NONE guibg=NONE
]]
