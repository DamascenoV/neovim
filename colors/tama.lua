-- tama.lua
-- A clean, dark, high-contrast colorscheme for Neovim

vim.cmd.hi('clear')
vim.g.colors_name = 'tama'

local hi = vim.api.nvim_set_hl
local link = function(target, source) hi(0, target, { link = source }) end

-- ===========================================================================
-- COLOR PALETTE
-- ===========================================================================

local c = {
  -- Backgrounds
  bg = '#181a1b',
  bg_dark = '#131515',
  bg_darker = '#1d2023',
  bg_alt = '#131515',
  bg_float = '#181a1b',
  bg_status = '#34373a',

  -- Foregrounds
  fg = '#d1d1d1',
  fg_light = '#d1d1d1',
  fg_dark = '#5c6366',
  fg_gutter = '#5c6366',

  -- Accents
  red = '#c15959',
  green = '#37ad82',
  yellow = '#fac03b',
  orange = '#ffb354',
  blue = '#7398dd',
  purple = '#ca70d6',
  cyan = '#a3db81',
  magenta = '#a29bfe',

  -- Spell & special underlines
  spell_bad = '#ffc0b9',
  spell_cap = '#fce094',
  spell_local = '#b3f6c0',
  spell_rare = '#8cf8f7',
  snippet_cur = '#fce094',
  snippet_rep = '#ffc0b9',
  snippet_fin = '#b3f6c0',
  snippet_unv = '#a6dbff',
  snippet_vis = '#8cf8f7',
}

-- ===========================================================================
-- EDITOR UI
-- ===========================================================================

hi(0, 'Normal', { fg = c.fg, bg = c.bg })
hi(0, 'NormalFloat', { fg = c.fg, bg = c.bg_float })
hi(0, 'FloatBorder', { fg = c.fg_gutter, bg = c.bg_float })
hi(0, 'ColorColumn', { bg = c.bg_darker })
hi(0, 'Cursor', { fg = c.bg, bg = c.fg_light, reverse = true })
hi(0, 'lCursor', { fg = c.bg, bg = c.fg_light })
hi(0, 'CursorLine', { bg = c.bg_darker })
hi(0, 'CursorColumn', { bg = c.bg_darker })
hi(0, 'CursorLineNr', { fg = c.orange, bg = c.bg_darker, bold = true })
hi(0, 'LineNr', { fg = c.fg_gutter, bg = c.bg_darker })
hi(0, 'Folded', { fg = '#a1a1a1', bg = c.bg_status })
hi(0, 'FoldColumn', { fg = c.bg_alt, bg = c.bg_dark })
hi(0, 'SignColumn', { fg = c.bg, bg = c.bg })
hi(0, 'EndOfBuffer', { fg = c.bg_alt })
hi(0, 'NonText', { fg = c.fg_gutter, bg = c.bg })
hi(0, 'Conceal', { fg = c.red })
hi(0, 'Directory', { fg = c.yellow })

-- Pmenu
hi(0, 'Pmenu', { fg = c.fg, bg = c.bg_darker })
hi(0, 'PmenuSel', { fg = c.bg, bg = c.yellow, bold = true })
hi(0, 'PmenuSbar', { bg = c.bg_darker })
hi(0, 'PmenuThumb', { bg = c.cyan })

-- Status & Tab lines
-- hi(0, 'StatusLine', { fg = c.fg_light, bg = c.bg_status })
-- hi(0, 'StatusLineNC', { fg = c.fg_gutter, bg = c.bg_status })
hi(0, 'StatusLine', { link = 'MsgSeparator' })
hi(0, 'StatusLineNC', { link = 'MsgSeparator' })
hi(0, 'TabLineFill', { fg = c.fg, bg = c.bg_darker })
hi(0, 'TabLineSel', { fg = c.fg_light, bg = c.bg_status, bold = true })

-- Splits & Visual
hi(0, 'VertSplit', { fg = c.bg_alt, bg = c.bg_alt })
hi(0, 'Visual', { bg = '#2d3032' })
hi(0, 'VisualNOS', { fg = c.fg, bg = c.bg })

-- Search
hi(0, 'Search', { fg = c.orange, bg = c.bg, bold = true, reverse = true })
hi(0, 'IncSearch', { fg = c.orange, bg = c.bg, bold = true, reverse = true })
hi(0, 'Substitute', { fg = c.orange, bg = c.bg, bold = true, reverse = true })

-- Messages
hi(0, 'ErrorMsg', { fg = c.red })
hi(0, 'WarningMsg', { fg = c.yellow })
hi(0, 'ModeMsg', { fg = c.orange })
hi(0, 'MoreMsg', { fg = c.cyan })
hi(0, 'Question', { fg = c.fg })
hi(0, 'MsgSeparator', { bg = 'bg', fg = 'fg' })

-- MatchParen
hi(0, 'MatchParen', { fg = c.orange, bold = true })

-- Spell
hi(0, 'SpellBad', { fg = c.red, sp = c.spell_bad, underline = true, bold = true })
hi(0, 'SpellCap', { fg = c.red, sp = c.spell_cap, underline = true, bold = true })
hi(0, 'SpellLocal', { fg = c.orange, sp = c.spell_local, underline = true, bold = true })
hi(0, 'SpellRare', { fg = c.orange, sp = c.spell_rare, underline = true, bold = true })

-- Mini
hi(0, 'MiniPickMatchCurrent', { bg = c.bg_status, underline = true, bold = true })
hi(0, 'MiniFilesCursorLine', { bg = c.bg_status, underline = true, bold = true })

-- ===========================================================================
-- SYNTAX HIGHLIGHTING
-- ===========================================================================

hi(0, 'Comment', { fg = c.fg_gutter, italic = true })

hi(0, 'Constant', { fg = c.magenta })
hi(0, 'String', { fg = c.green })
hi(0, 'Character', { fg = c.green })
hi(0, 'Number', { fg = c.magenta })
hi(0, 'Boolean', { fg = c.magenta })
hi(0, 'Float', { fg = c.magenta })

hi(0, 'Identifier', { fg = c.fg })
hi(0, 'Function', { fg = c.fg })

hi(0, 'Statement', { fg = c.yellow, bold = true })
hi(0, 'Conditional', { link = 'Statement' })
hi(0, 'Repeat', { link = 'Statement' })
hi(0, 'Label', { link = 'Statement' })
hi(0, 'Operator', { fg = c.cyan })
hi(0, 'Keyword', { fg = c.yellow, bold = true })
hi(0, 'Exception', { fg = c.yellow, bold = true })

hi(0, 'PreProc', { fg = c.magenta })
hi(0, 'Include', { link = 'PreProc' })
hi(0, 'Define', { link = 'PreProc' })
hi(0, 'Macro', { link = 'PreProc' })
hi(0, 'PreCondit', { link = 'PreProc' })

hi(0, 'Type', { fg = c.blue })
hi(0, 'StorageClass', { link = 'Statement' })
hi(0, 'Structure', { link = 'Statement' })
hi(0, 'Typedef', { link = 'Statement' })

hi(0, 'Special', { fg = c.orange })
hi(0, 'SpecialKey', { fg = c.orange })
hi(0, 'Delimiter', { fg = c.fg })
hi(0, 'SpecialComment', { fg = c.orange, bold = true })
hi(0, 'Debug', { fg = c.red })

hi(0, 'Underlined', { fg = c.cyan, underline = true })
hi(0, 'Ignore', { fg = c.fg_gutter })
hi(0, 'Error', { fg = c.red, bold = true })
hi(0, 'Todo', { fg = c.bg, bg = c.green, bold = true })

-- ===========================================================================
-- DIFF
-- ===========================================================================

hi(0, 'DiffAdd', { fg = c.green, bg = c.bg_dark })
hi(0, 'DiffChange', { fg = c.yellow, bg = c.bg_dark })
hi(0, 'DiffDelete', { fg = c.red, bold = true, bg = c.bg_dark })
hi(0, 'DiffText', { fg = c.cyan, bg = c.bg_dark })

-- ===========================================================================
-- PLUGINS & LSP
-- ===========================================================================

-- Neomake
link('NeomakeErrorSign', 'ErrorMsg')
link('NeomakeWarningSign', 'WarningMsg')
link('NeomakeInfoSign', 'Type')
link('NeomakeMessageSign', 'WarningMsg')
link('NeomakeVirtualtextError', 'ErrorMsg')
link('NeomakeVirtualtextWarning', 'WarningMsg')
link('NeomakeVirtualtextInfo', 'Type')
link('NeomakeVirtualtextMessage', 'WarningMsg')

-- MiniSnippets
hi(0, 'MiniSnippetsCurrent', { sp = c.snippet_cur, underdouble = true })
hi(0, 'MiniSnippetsCurrentReplace', { sp = c.snippet_rep, underdouble = true })
hi(0, 'MiniSnippetsFinal', { sp = c.snippet_fin, underdouble = true })
hi(0, 'MiniSnippetsUnvisited', { sp = c.snippet_unv, underdouble = true })
hi(0, 'MiniSnippetsVisited', { sp = c.snippet_vis, underdouble = true })
hi(0, 'MiniPickCursor', { blend = 100, nocombine = true })

-- Debug
hi(0, 'debugPC', { fg = c.red })
hi(0, 'debugBreakpoint', { fg = c.red })

-- ===========================================================================
-- FILETYPE SPECIFIC
-- ===========================================================================

-- Vimdoc
hi(
  0,
  '@markup.heading.1.delimiter.vimdoc',
  { fg = c.bg, bg = c.bg, sp = c.fg_light, underdouble = true, nocombine = true }
)
hi(
  0,
  '@markup.heading.2.delimiter.vimdoc',
  { fg = c.bg, bg = c.bg, sp = c.fg_light, underline = true, nocombine = true }
)

-- HTML / JSX
link('htmlTag', 'Normal')
link('htmlEndTag', 'htmlTagName')
link('htmlTagName', 'Statement')
link('htmlSpecialTagName', 'htmlTagName')
link('htmlArg', 'Operator')
link('htmlBold', 'Normal')
link('htmlItalic', 'Normal')
link('htmlLink', 'Function')
link('jsxComponentName', 'Statement')
link('jsxTagName', 'Special')

-- Markdown
link('markdownCode', 'String')
link('markdownCodeBlock', 'String')
link('markdownCodeDelimiter', 'String')
link('markdownHeadingDelimiter', 'Type')
link('markdownItalic', 'PreProc')
link('markdownLinkText', 'Special')

-- CSS
link('cssClassName', 'Statement')
link('cssProp', 'Special')
link('cssDefinition', 'Special')
link('cssTagName', 'SpecialKey')

-- YAML
link('yamlBlockMappingKey', 'Statement')
link('yamlFlowIndicator', 'SpecialKey')

-- XML
link('xmlTag', 'Statement')
link('xmlTagName', 'Statement')
link('xmlEndTag', 'Statement')

-- Others
link('pythonBuiltin', 'Constant')
link('fugitiveHash', 'Constant')
link('ConId', 'Type')
link('HelpCommand', 'Statement')
link('HelpExample', 'Statement')
link('Terminal', 'Normal')

-- Diff
link('diffAdded', 'DiffAdd')
link('diffRemoved', 'DiffDelete')
link('diffBDiffer', 'WarningMsg')
link('diffCommon', 'WarningMsg')
link('diffDiffer', 'WarningMsg')
link('diffIdentical', 'WarningMsg')
link('diffIsA', 'WarningMsg')
link('diffNoEOL', 'WarningMsg')
link('diffOnly', 'WarningMsg')

-- ===========================================================================
-- TERMINAL COLORS
-- ===========================================================================

vim.g.terminal_color_0 = c.bg
vim.g.terminal_color_1 = c.red
vim.g.terminal_color_2 = c.green
vim.g.terminal_color_3 = c.yellow
vim.g.terminal_color_4 = c.blue
vim.g.terminal_color_5 = c.purple
vim.g.terminal_color_6 = c.cyan
vim.g.terminal_color_7 = c.fg_gutter
vim.g.terminal_color_8 = c.bg_alt
vim.g.terminal_color_9 = c.red
vim.g.terminal_color_10 = c.green
vim.g.terminal_color_11 = c.orange
vim.g.terminal_color_12 = c.blue
vim.g.terminal_color_13 = c.magenta
vim.g.terminal_color_14 = c.cyan
vim.g.terminal_color_15 = c.fg_light

-- Optional: Recommend settings
vim.o.background = 'dark'
vim.o.termguicolors = true
