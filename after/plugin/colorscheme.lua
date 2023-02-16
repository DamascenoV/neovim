require("colorbuddy").colorscheme "gruvbuddy"
require("colorizer").setup()

local c = require("colorbuddy.color").colors
local Group = require("colorbuddy.group").Group
local g = require("colorbuddy.group").groups
local s = require("colorbuddy.style").styles

Group.new("@variable", c.superwhite, nil)
Group.new("@variable.builtin", c.purple:light():light(), g.Normal)
Group.new("@function.call", c.blue:light(), nil)
Group.new("@function", c.blue:light(), nil)
Group.new("@type", c.red, nil)
Group.new("@type.qualifier", c.purple:light(), nil)
Group.new("@method.call", c.blue:light(), nil)
Group.new("@property", c.superwhite, nil)
Group.new("@field", c.superwhite, nil)
Group.new("GoTestSuccess", c.green, nil, s.bold)
Group.new("GoTestFail", c.red, nil, s.bold)
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
Group.new("TSTitle", c.blue)
Group.new("InjectedLanguage", nil, g.Normal.bg:dark())
Group.new("LspParameter", nil, nil, s.italic)
Group.new("LspDeprecated", nil, nil, s.strikethrough)
Group.new("@function.bracket", g.Normal, g.Normal)
Group.new("CmpItemAbbr", g.Comment)
Group.new("CmpItemAbbrDeprecated", g.Error)
Group.new("CmpItemAbbrMatchFuzzy", g.CmpItemAbbr.fg:dark(), nil, s.italic)
Group.new("CmpItemKind", g.Special)
Group.new("CmpItemMenu", g.NonText)
Group.new("GitSignsAdd", c.green)
Group.new("GitSignsChange", c.yellow)
Group.new("GitSignsDelete", c.red)

vim.cmd [[
highlight link @function.call.lua LuaFunctionCall
highlight LineNr term=bold cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guibg=NONE
highlight ColorColumn guibg=Grey
highlight clear SignColumn
hi! Normal ctermbg=NONE guibg=NONE
]]
