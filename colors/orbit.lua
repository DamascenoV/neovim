-- orbit.lua
-- A minimal, high-contrast dark colorscheme for Neovim

vim.cmd.hi("clear")
vim.g.colors_name = "orbit"

local hi = vim.api.nvim_set_hl
local link = function(target, source)
  hi(0, target, { link = source })
end

-- ===========================================================================
-- COLOR PALETTE (Minimal: only 6 colors)
-- ===========================================================================

local c = {
  bg        = "#050505",  -- Pitch black
  fg        = "#e6e6e6",  -- High contrast white
  teal      = "#73c9c0",  -- Keywords, types, function calls
  lime      = "#bec962",  -- Strings, numbers, constants
  gold      = "#dcdcaa",  -- Function definitions
  grey      = "#505050",  -- Comments, line numbers, UI
  dark_grey = "#2d2d2d",  -- Selection, backgrounds
  red       = "#e06c75",  -- Errors
  bg_alt    = "#131515",  -- Pitch black
}

-- ===========================================================================
-- EDITOR UI
-- ===========================================================================

hi(0, "Normal", { fg = c.fg, bg = c.bg })
hi(0, "NormalFloat", { fg = c.fg, bg = c.bg })
hi(0, "FloatBorder", { fg = c.grey, bg = c.bg })
hi(0, "ColorColumn", { bg = c.dark_grey })
hi(0, "Cursor", { fg = c.bg, bg = c.fg, reverse = true })
hi(0, "lCursor", { fg = c.bg, bg = c.fg })
hi(0, "CursorLine", { bg = c.bg_alt })
hi(0, "CursorColumn", { bg = c.dark_grey })
hi(0, "CursorLineNr", { fg = c.fg, bold = true })
hi(0, "LineNr", { fg = c.grey })
hi(0, "Folded", { fg = c.grey, bg = c.dark_grey })
hi(0, "FoldColumn", { fg = c.grey, bg = c.bg })
hi(0, "SignColumn", { bg = c.bg })
hi(0, "EndOfBuffer", { fg = c.fg })
hi(0, "NonText", { fg = c.grey })
hi(0, "Conceal", { fg = c.grey })
hi(0, "Directory", { fg = c.gold })

-- Pmenu
hi(0, "Pmenu", { fg = c.fg, bg = c.bg })
hi(0, "PmenuSel", { fg = c.bg, bg = c.teal, bold = true })
hi(0, "PmenuSbar", { bg = c.bg })
hi(0, "PmenuThumb", { bg = c.teal })

-- Status & Tab lines
hi(0, "StatusLine", { fg = c.fg, bg = c.dark_grey })
hi(0, "StatusLineNC", { fg = c.grey, bg = c.dark_grey })
hi(0, "TabLine", { fg = c.fg, bg = c.dark_grey })
hi(0, "TabLineFill", { fg = c.fg, bg = c.dark_grey })
hi(0, "TabLineSel", { fg = c.fg, bg = c.grey, bold = true })

-- Splits & Visual
hi(0, "VertSplit", { fg = c.dark_grey, bg = c.dark_grey })
hi(0, "Visual", { bg = c.dark_grey })
hi(0, "VisualNOS", { bg = c.dark_grey })

-- Search
hi(0, "Search", { fg = c.bg, bg = c.gold, bold = true })
hi(0, "IncSearch", { fg = c.bg, bg = c.gold, bold = true })
hi(0, "Substitute", { fg = c.bg, bg = c.gold, bold = true })

-- Messages
hi(0, "ErrorMsg", { fg = c.red })
hi(0, "WarningMsg", { fg = c.gold })
hi(0, "ModeMsg", { fg = c.teal })
hi(0, "MoreMsg", { fg = c.lime })
hi(0, "Question", { fg = c.fg })

-- MatchParen
hi(0, "MatchParen", { fg = c.gold, bold = true })

-- Spell
hi(0, "SpellBad", { sp = c.red, underline = true })
hi(0, "SpellCap", { sp = c.gold, underline = true })
hi(0, "SpellLocal", { sp = c.lime, underline = true })
hi(0, "SpellRare", { sp = c.teal, underline = true })

-- Mini
hi(0, "MiniPickMatchCurrent", { bg = c.bg_alt, underline = true, bold = true })
hi(0, "MiniFilesCursorLine", { bg = c.bg_alt, underline = true, bold = true })
hi(0, "MiniPickCursor", { blend = 100, nocombine = true })

-- ===========================================================================
-- SYNTAX HIGHLIGHTING
-- ===========================================================================

hi(0, "Comment", { fg = c.grey, italic = true })

hi(0, "Constant", { fg = c.lime })
hi(0, "String", { fg = c.lime })
hi(0, "Character", { fg = c.lime })
hi(0, "Number", { fg = c.lime })
hi(0, "Boolean", { fg = c.lime })
hi(0, "Float", { fg = c.lime })

hi(0, "Identifier", { fg = c.fg })
hi(0, "Function", { fg = c.teal })

hi(0, "Statement", { fg = c.teal })
link("Conditional", "Statement")
link("Repeat", "Statement")
link("Label", "Statement")
hi(0, "Operator", { fg = c.fg })
hi(0, "Keyword", { fg = c.teal })
hi(0, "Exception", { fg = c.teal })

hi(0, "PreProc", { fg = c.teal })
link("Include", "PreProc")
link("Define", "PreProc")
link("Macro", "PreProc")
link("PreCondit", "PreProc")

hi(0, "Type", { fg = c.teal })
link("StorageClass", "Statement")
link("Structure", "Statement")
link("Typedef", "Statement")

hi(0, "Special", { fg = c.fg })
hi(0, "SpecialKey", { fg = c.grey })
hi(0, "Delimiter", { fg = c.fg })
hi(0, "SpecialComment", { fg = c.gold })
hi(0, "Debug", { fg = c.red })

hi(0, "Underlined", { fg = c.teal, underline = true })
hi(0, "Ignore", { fg = c.grey })
hi(0, "Error", { fg = c.red, bold = true })
hi(0, "Todo", { fg = c.bg, bg = c.lime, bold = true })

-- ===========================================================================
-- TREESITTER
-- ===========================================================================

hi(0, "@variable", { fg = c.fg })
hi(0, "@variable.member", { fg = c.fg })
hi(0, "@variable.parameter", { fg = c.fg })
hi(0, "@property", { fg = c.fg })

hi(0, "@keyword", { fg = c.teal })
hi(0, "@keyword.function", { fg = c.teal })
hi(0, "@keyword.return", { fg = c.teal })
hi(0, "@keyword.operator", { fg = c.teal })

hi(0, "@type", { fg = c.teal })
hi(0, "@type.builtin", { fg = c.teal })
hi(0, "@type.definition", { fg = c.fg, bold = true })

hi(0, "@function", { fg = c.fg })
hi(0, "@function.call", { fg = c.teal })
hi(0, "@function.builtin", { fg = c.teal })
hi(0, "@method", { fg = c.gold })
hi(0, "@method.call", { fg = c.teal })

hi(0, "@constructor", { fg = c.teal })
hi(0, "@operator", { fg = c.fg })
hi(0, "@punctuation", { fg = c.fg })
hi(0, "@punctuation.bracket", { fg = c.fg })
hi(0, "@punctuation.delimiter", { fg = c.fg })

hi(0, "@string", { fg = c.lime })
hi(0, "@string.escape", { fg = c.gold })
hi(0, "@character", { fg = c.lime })
hi(0, "@number", { fg = c.lime })
hi(0, "@boolean", { fg = c.lime })
hi(0, "@float", { fg = c.lime })

hi(0, "@comment", { fg = c.grey, italic = true })
hi(0, "@constant", { fg = c.lime })
hi(0, "@constant.builtin", { fg = c.lime })

hi(0, "@attribute", { fg = c.teal })
hi(0, "@namespace", { fg = c.fg })
hi(0, "@module", { fg = c.fg })

-- ===========================================================================
-- DIFF
-- ===========================================================================

hi(0, "DiffAdd", { fg = c.lime })
hi(0, "DiffChange", { fg = c.gold })
hi(0, "DiffDelete", { fg = c.red, bold = true })
hi(0, "DiffText", { fg = c.teal })

-- ===========================================================================
-- PLUGINS & LSP
-- ===========================================================================

link("NeomakeErrorSign", "ErrorMsg")
link("NeomakeWarningSign", "WarningMsg")
link("NeomakeInfoSign", "Type")
link("NeomakeMessageSign", "WarningMsg")
link("NeomakeVirtualtextError", "ErrorMsg")
link("NeomakeVirtualtextWarning", "WarningMsg")
link("NeomakeVirtualtextInfo", "Type")
link("NeomakeVirtualtextMessage", "WarningMsg")

-- MiniSnippets
hi(0, "MiniSnippetsCurrent", { sp = c.gold, underdouble = true })
hi(0, "MiniSnippetsCurrentReplace", { sp = c.red, underdouble = true })
hi(0, "MiniSnippetsFinal", { sp = c.lime, underdouble = true })
hi(0, "MiniSnippetsUnvisited", { sp = c.teal, underdouble = true })
hi(0, "MiniSnippetsVisited", { sp = c.grey, underdouble = true })

-- Debug
hi(0, "debugPC", { fg = c.red })
hi(0, "debugBreakpoint", { fg = c.red })

-- ===========================================================================
-- FILETYPE SPECIFIC
-- ===========================================================================

-- Vimdoc
hi(0, "@markup.heading.1.delimiter.vimdoc", { fg = c.bg, bg = c.bg, sp = c.fg, underdouble = true, nocombine = true })
hi(0, "@markup.heading.2.delimiter.vimdoc", { fg = c.bg, bg = c.bg, sp = c.fg, underline = true, nocombine = true })

-- HTML / JSX
link("htmlTag", "Normal")
link("htmlEndTag", "htmlTagName")
link("htmlTagName", "Statement")
link("htmlSpecialTagName", "htmlTagName")
link("htmlArg", "Operator")
link("htmlBold", "Normal")
link("htmlItalic", "Normal")
link("htmlLink", "Function")
link("jsxComponentName", "Statement")
link("jsxTagName", "Special")

-- Markdown
link("markdownCode", "String")
link("markdownCodeBlock", "String")
link("markdownCodeDelimiter", "String")
link("markdownHeadingDelimiter", "Type")
link("markdownItalic", "PreProc")
link("markdownLinkText", "Special")

-- CSS
link("cssClassName", "Statement")
link("cssProp", "Special")
link("cssDefinition", "Special")
link("cssTagName", "SpecialKey")

-- YAML
link("yamlBlockMappingKey", "Statement")
link("yamlFlowIndicator", "SpecialKey")

-- XML
link("xmlTag", "Statement")
link("xmlTagName", "Statement")
link("xmlEndTag", "Statement")

-- Others
link("pythonBuiltin", "Constant")
link("fugitiveHash", "Constant")
link("ConId", "Type")
link("HelpCommand", "Statement")
link("HelpExample", "Statement")
link("Terminal", "Normal")

-- Diff
link("diffAdded", "DiffAdd")
link("diffRemoved", "DiffDelete")
link("diffBDiffer", "WarningMsg")
link("diffCommon", "WarningMsg")
link("diffDiffer", "WarningMsg")
link("diffIdentical", "WarningMsg")
link("diffIsA", "WarningMsg")
link("diffNoEOL", "WarningMsg")
link("diffOnly", "WarningMsg")

-- ===========================================================================
-- TERMINAL COLORS
-- ===========================================================================

vim.g.terminal_color_0  = c.bg
vim.g.terminal_color_1  = c.red
vim.g.terminal_color_2  = c.lime
vim.g.terminal_color_3  = c.gold
vim.g.terminal_color_4  = c.teal
vim.g.terminal_color_5  = c.teal
vim.g.terminal_color_6  = c.teal
vim.g.terminal_color_7  = c.grey
vim.g.terminal_color_8  = c.dark_grey
vim.g.terminal_color_9  = c.red
vim.g.terminal_color_10 = c.lime
vim.g.terminal_color_11 = c.gold
vim.g.terminal_color_12 = c.teal
vim.g.terminal_color_13 = c.teal
vim.g.terminal_color_14 = c.teal
vim.g.terminal_color_15 = c.fg

vim.o.background        = "dark"
vim.o.termguicolors     = true
