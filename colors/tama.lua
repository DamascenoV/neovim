-- tama.lua
-- A clean, dark, high-contrast colorscheme for Neovim.

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
  bg_alt = '#242629',
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

  diff_add_bg = '#365a35',
  diff_delete_bg = '#6a3334',

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
hi(0, 'NormalNC', { fg = c.fg, bg = c.bg })
hi(0, 'NormalFloat', { fg = c.fg, bg = c.bg })
hi(0, 'FloatBorder', { fg = c.fg_dark, bg = c.bg })
hi(0, 'FloatTitle', { fg = c.yellow, bg = c.bg, bold = true })
hi(0, 'FloatFooter', { fg = c.fg_dark, bg = c.bg })
hi(0, 'ColorColumn', { bg = c.bg_darker })
hi(0, 'Cursor', { fg = c.bg, bg = c.fg_light })
hi(0, 'lCursor', { fg = c.bg, bg = c.fg_light })
hi(0, 'CursorIM', { fg = c.bg, bg = c.fg_light })
hi(0, 'CursorLine', { bg = c.bg_darker })
hi(0, 'CursorColumn', { bg = c.bg_darker })
hi(0, 'CursorLineNr', { fg = c.orange, bg = c.bg_darker, bold = true })
hi(0, 'LineNr', { fg = c.fg_gutter, bg = c.bg_darker })
hi(0, 'LineNrAbove', { fg = c.fg_gutter, bg = c.bg_darker })
hi(0, 'LineNrBelow', { fg = c.fg_gutter, bg = c.bg_darker })
hi(0, 'FoldColumn', { fg = c.fg_gutter, bg = c.bg_dark })
hi(0, 'Folded', { fg = c.fg_dark, bg = c.bg_dark })
hi(0, 'SignColumn', { fg = c.fg_gutter, bg = c.bg })
hi(0, 'EndOfBuffer', { fg = c.bg_dark })
hi(0, 'NonText', { fg = c.fg_dark, bg = c.bg })
hi(0, 'Whitespace', { fg = c.fg_dark })
hi(0, 'Conceal', { fg = c.red })
hi(0, 'Directory', { fg = c.yellow })
hi(0, 'Title', { fg = c.yellow, bold = true })
hi(0, 'QuickFixLine', { bg = c.bg_status })

-- Pmenu / wildmenu
hi(0, 'Pmenu', { fg = c.fg, bg = c.bg_darker })
hi(0, 'PmenuSel', { fg = c.bg, bg = c.yellow, bold = true })
hi(0, 'PmenuKind', { fg = c.blue, bg = c.bg_darker })
hi(0, 'PmenuExtra', { fg = c.fg_dark, bg = c.bg_darker })
hi(0, 'PmenuKindSel', { fg = c.bg, bg = c.yellow, bold = true })
hi(0, 'PmenuExtraSel', { fg = c.bg, bg = c.yellow })
hi(0, 'PmenuSbar', { bg = c.bg_darker })
hi(0, 'PmenuThumb', { bg = c.cyan })
hi(0, 'WildMenu', { fg = c.bg, bg = c.yellow, bold = true })
hi(0, 'ComplMatchIns', { fg = c.green, bold = true })

-- Status, tab, and window bars
hi(0, 'StatusLine', { fg = c.fg_light, bg = c.bg })
hi(0, 'StatusLineNC', { fg = c.fg_gutter, bg = c.bg })
hi(0, 'TabLine', { fg = c.fg_dark, bg = c.bg_darker })
hi(0, 'TabLineFill', { fg = c.fg_dark, bg = c.bg_darker })
hi(0, 'TabLineSel', { fg = c.yellow, bg = c.bg, bold = true })
hi(0, 'WinBar', { fg = c.fg_light, bg = c.bg_status })
hi(0, 'WinBarNC', { fg = c.fg_gutter, bg = c.bg_status })
hi(0, 'VertSplit', { fg = c.bg_alt, bg = c.bg_alt })
hi(0, 'WinSeparator', { fg = c.bg_alt, bg = c.bg_alt })

-- Splits & Visual
hi(0, 'Visual', { bg = '#2d3032' })
hi(0, 'VisualNOS', { fg = c.fg, bg = c.bg_alt })

-- Search
hi(0, 'Search', { fg = c.orange, bg = c.bg, bold = true, reverse = true })
hi(0, 'IncSearch', { fg = c.orange, bg = c.bg, bold = true, reverse = true })
hi(0, 'CurSearch', { fg = c.orange, bg = c.bg, bold = true, reverse = true })
hi(0, 'Substitute', { fg = c.orange, bg = c.bg, bold = true, reverse = true })

-- Messages
hi(0, 'ErrorMsg', { fg = c.red, bold = true })
hi(0, 'WarningMsg', { fg = c.yellow })
hi(0, 'ModeMsg', { fg = c.orange })
hi(0, 'MoreMsg', { fg = c.cyan })
hi(0, 'Question', { fg = c.fg })
hi(0, 'MsgArea', { fg = c.fg, bg = c.bg })
hi(0, 'MsgSeparator', { fg = c.fg, bg = c.bg })

-- MatchParen
hi(0, 'MatchParen', { fg = c.orange, bold = true })

-- Spell
hi(0, 'SpellBad', { sp = c.spell_bad })
hi(0, 'SpellCap', { sp = c.spell_cap })
hi(0, 'SpellLocal', { sp = c.spell_local })
hi(0, 'SpellRare', { sp = c.spell_rare })

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
hi(0, 'Structure', { link = 'Type' })
hi(0, 'Typedef', { link = 'Type' })

hi(0, 'Special', { fg = c.orange })
hi(0, 'SpecialKey', { fg = c.orange })
hi(0, 'Delimiter', { fg = c.fg })
hi(0, 'SpecialComment', { fg = c.orange, bold = true })
hi(0, 'Debug', { fg = c.red })

hi(0, 'Underlined', { fg = c.cyan, underline = true })
hi(0, 'Ignore', { fg = c.fg_dark })
hi(0, 'Error', { fg = c.red, bold = true })
hi(0, 'Todo', { fg = c.bg, bg = c.green, bold = true })

-- ===========================================================================
-- TREESITTER
-- ===========================================================================

link('@comment', 'Comment')
hi(0, '@comment.documentation', { fg = c.fg_gutter })
link('@comment.error', 'Error')
link('@comment.warning', 'WarningMsg')
link('@comment.todo', 'Todo')
link('@comment.note', 'MoreMsg')

link('@constant', 'Constant')
link('@constant.builtin', 'Constant')
link('@constant.macro', 'PreProc')
link('@string', 'String')
hi(0, '@string.documentation', { fg = c.fg_gutter })
link('@string.escape', 'Special')
link('@string.regexp', 'Special')
link('@string.special', 'Special')
link('@string.special.path', 'String')
link('@string.special.url', 'Underlined')
link('@string.special.symbol', 'Constant')
link('@character', 'Character')
link('@character.special', 'Special')
link('@boolean', 'Boolean')
link('@number', 'Number')
link('@number.float', 'Float')

link('@variable', 'Identifier')
link('@variable.parameter', 'Identifier')
link('@variable.member', 'Identifier')
link('@variable.builtin', 'Constant')
link('@property', 'Identifier')
link('@field', 'Identifier')
link('@parameter', 'Identifier')

link('@function', 'Function')
link('@function.call', 'Function')
link('@function.method', 'Function')
link('@function.method.call', 'Function')
link('@function.builtin', 'Function')
link('@function.macro', 'Function')
link('@method', 'Function')
link('@method.call', 'Function')
link('@constructor', 'Type')

link('@keyword', 'Keyword')
link('@keyword.conditional', 'Conditional')
link('@keyword.coroutine', 'Keyword')
link('@keyword.debug', 'Debug')
link('@keyword.directive', 'PreProc')
link('@keyword.directive.define', 'Define')
link('@keyword.exception', 'Exception')
link('@keyword.function', 'Keyword')
link('@keyword.import', 'Include')
link('@keyword.operator', 'Operator')
link('@keyword.repeat', 'Repeat')
link('@keyword.return', 'Keyword')
link('@keyword.storage', 'StorageClass')
link('@conditional', 'Conditional')
link('@repeat', 'Repeat')
link('@include', 'Include')
link('@exception', 'Exception')
link('@operator', 'Operator')

link('@type', 'Type')
link('@type.builtin', 'Type')
link('@type.definition', 'Typedef')
link('@type.qualifier', 'StorageClass')
link('@module', 'Type')
link('@module.builtin', 'Type')
link('@namespace', 'Type')
link('@label', 'Label')
link('@attribute', 'PreProc')
link('@annotation', 'PreProc')

link('@punctuation.delimiter', 'Delimiter')
link('@punctuation.bracket', 'Delimiter')
link('@punctuation.special', 'Special')

link('@markup.strong', 'Special')
link('@markup.italic', 'Comment')
link('@markup.strikethrough', 'Comment')
link('@markup.link', 'Underlined')
link('@markup.link.label', 'Special')
link('@markup.link.url', 'Underlined')

link('@tag', 'Keyword')
link('@tag.attribute', 'Identifier')
link('@tag.delimiter', 'Delimiter')

link('@diff.plus', 'DiffAdd')
link('@diff.minus', 'DiffDelete')
link('@diff.delta', 'DiffChange')

-- Elixir-specific.
link('@module.elixir', 'Type')
link('@string.special.symbol.elixir', 'Constant')
hi(0, '@comment.documentation.elixir', { fg = c.fg_gutter })
link('@function.call.elixir', 'Function')
link('@function.elixir', 'Function')
link('@variable.elixir', 'Identifier')
link('@variable.parameter.elixir', 'Identifier')
link('@variable.member.elixir', 'Identifier')
link('@property.elixir', 'Identifier')

-- LSP semantic tokens, kept in the same palette as Treesitter.
link('@lsp.type.class', 'Type')
link('@lsp.type.comment', 'Comment')
link('@lsp.type.decorator', 'PreProc')
link('@lsp.type.enum', 'Type')
link('@lsp.type.enumMember', 'Constant')
link('@lsp.type.event', 'Type')
link('@lsp.type.function', 'Function')
link('@lsp.type.interface', 'Type')
link('@lsp.type.keyword', 'Keyword')
link('@lsp.type.macro', 'PreProc')
link('@lsp.type.method', 'Function')
link('@lsp.type.modifier', 'StorageClass')
link('@lsp.type.namespace', 'Type')
link('@lsp.type.number', 'Number')
link('@lsp.type.operator', 'Operator')
link('@lsp.type.parameter', 'Identifier')
link('@lsp.type.property', 'Identifier')
link('@lsp.type.regexp', 'Special')
link('@lsp.type.string', 'String')
link('@lsp.type.struct', 'Type')
link('@lsp.type.type', 'Type')
link('@lsp.type.typeParameter', 'Type')
link('@lsp.type.variable', 'Identifier')
link('@lsp.typemod.variable.defaultLibrary', 'Constant')
link('@lsp.typemod.function.defaultLibrary', 'Function')
link('@lsp.typemod.method.defaultLibrary', 'Function')

-- ===========================================================================
-- DIFF / DIAGNOSTICS / LSP UI
-- ===========================================================================

hi(0, 'DiffAdd', { fg = c.fg_light, bg = c.diff_add_bg })
hi(0, 'DiffChange', { fg = c.fg_light, bg = c.bg_dark })
hi(0, 'DiffDelete', { fg = c.fg_light, bg = c.diff_delete_bg })
hi(0, 'DiffText', { fg = c.fg_light, bg = c.bg_status })

hi(0, 'Added', { fg = c.green })
hi(0, 'Changed', { fg = c.yellow })
hi(0, 'Removed', { fg = c.red })

hi(0, 'DiagnosticError', { fg = c.red, bold = true })
hi(0, 'DiagnosticWarn', { fg = c.yellow })
hi(0, 'DiagnosticInfo', { fg = c.blue })
hi(0, 'DiagnosticHint', { fg = c.cyan })
hi(0, 'DiagnosticOk', { fg = c.green })
hi(0, 'DiagnosticVirtualTextError', { fg = c.red, bg = c.bg_dark })
hi(0, 'DiagnosticVirtualTextWarn', { fg = c.yellow, bg = c.bg_dark })
hi(0, 'DiagnosticVirtualTextInfo', { fg = c.blue, bg = c.bg_dark })
hi(0, 'DiagnosticVirtualTextHint', { fg = c.cyan, bg = c.bg_dark })
hi(0, 'DiagnosticVirtualTextOk', { fg = c.green, bg = c.bg_dark })
hi(0, 'DiagnosticUnderlineError', { sp = c.red })
hi(0, 'DiagnosticUnderlineWarn', { sp = c.yellow })
hi(0, 'DiagnosticUnderlineInfo', { sp = c.blue })
hi(0, 'DiagnosticUnderlineHint', { sp = c.cyan })
hi(0, 'DiagnosticUnderlineOk', { sp = c.green })
link('DiagnosticSignError', 'DiagnosticError')
link('DiagnosticSignWarn', 'DiagnosticWarn')
link('DiagnosticSignInfo', 'DiagnosticInfo')
link('DiagnosticSignHint', 'DiagnosticHint')
link('DiagnosticSignOk', 'DiagnosticOk')
link('DiagnosticFloatingError', 'DiagnosticError')
link('DiagnosticFloatingWarn', 'DiagnosticWarn')
link('DiagnosticFloatingInfo', 'DiagnosticInfo')
link('DiagnosticFloatingHint', 'DiagnosticHint')
link('DiagnosticFloatingOk', 'DiagnosticOk')

hi(0, 'LspReferenceText', { bg = c.bg_darker })
hi(0, 'LspReferenceRead', { bg = c.bg_darker })
hi(0, 'LspReferenceWrite', { bg = c.bg_darker, underline = true })
hi(0, 'LspInlayHint', { fg = c.fg_dark, bg = c.bg_dark })
link('LspCodeLens', 'Comment')
link('LspCodeLensSeparator', 'Comment')
link('LspSignatureActiveParameter', 'Search')

-- ===========================================================================
-- PLUGINS & FILETYPE SPECIFIC
-- ===========================================================================

-- Native picker & explorer (util/picker.lua, util/explorer.lua)
hi(0, 'UtilPickerCurrent', { bg = c.bg_status, bold = true })
hi(0, 'UtilPickerMarked', { fg = c.green, bold = true })
hi(0, 'UtilPickerMatched', { fg = c.orange, bold = true })
hi(0, 'UtilPickerPrompt', { fg = c.green, bg = c.bg_darker, bold = true })
hi(0, 'UtilPickerPreviewLine', { bg = c.bg, bold = true })
link('UtilExplorerMeta', 'Comment')
link('UtilExplorerDirectory', 'Directory')
link('UtilExplorerFile', 'Normal')

-- Native VCS panel (util/vcs.lua)
hi(0, 'UtilVcsHeader', { fg = c.yellow, bg = c.bg_darker, bold = true })
link('UtilVcsHelp', 'Comment')
link('UtilVcsSection', 'Title')
hi(0, 'UtilVcsModified', { fg = c.orange, bold = true })
hi(0, 'UtilVcsAdded', { fg = c.green, bold = true })
hi(0, 'UtilVcsDeleted', { fg = c.red, bold = true })
hi(0, 'UtilVcsRenamed', { fg = c.blue, bold = true })
hi(0, 'UtilVcsUntracked', { fg = c.fg_dark, bold = true })
hi(0, 'UtilVcsConflict', { fg = c.red, bg = c.bg_status, bold = true })

-- Vimdoc / help
hi(0, '@markup.heading.1.delimiter.vimdoc', { fg = c.bg, bg = c.bg, sp = c.fg, underdouble = true, nocombine = true })
hi(0, '@markup.heading.2.delimiter.vimdoc', { fg = c.bg, bg = c.bg, sp = c.fg, underline = true, nocombine = true })
link('HelpCommand', 'Statement')
link('HelpExample', 'Statement')
link('helpHyperTextJump', 'Underlined')
link('helpOption', 'Type')

-- HTML / JSX / XML / Vue
link('htmlTag', 'Normal')
link('htmlEndTag', 'htmlTagName')
link('htmlTagName', 'Statement')
link('htmlSpecialTagName', 'htmlTagName')
link('htmlArg', 'Identifier')
link('htmlBold', 'Normal')
link('htmlItalic', 'Normal')
link('htmlLink', 'Underlined')
link('jsxComponentName', 'Type')
link('jsxTagName', 'Statement')
link('xmlTag', 'Statement')
link('xmlTagName', 'Statement')
link('xmlEndTag', 'Statement')
link('vueComponentName', 'Type')

-- Markdown
link('markdownCode', 'Comment')
link('markdownCodeBlock', 'Comment')
link('markdownCodeDelimiter', 'Comment')
link('markdownHeadingDelimiter', 'Comment')
link('markdownItalic', 'Comment')
link('markdownLinkText', 'Underlined')
link('markdownUrl', 'Underlined')

-- CSS / YAML / common filetypes
link('cssClassName', 'Statement')
link('cssProp', 'Identifier')
link('cssDefinition', 'Identifier')
link('cssTagName', 'SpecialKey')
link('yamlBlockMappingKey', 'Statement')
link('yamlFlowIndicator', 'SpecialKey')
link('jsonKeyword', 'Identifier')
link('jsonString', 'String')
link('pythonBuiltin', 'Constant')
link('ConId', 'Type')
link('Terminal', 'Normal')

-- Debug
hi(0, 'debugPC', { fg = c.red })
hi(0, 'debugBreakpoint', { fg = c.red })

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
vim.g.terminal_color_7 = c.fg_dark
vim.g.terminal_color_8 = c.bg_alt
vim.g.terminal_color_9 = c.red
vim.g.terminal_color_10 = c.green
vim.g.terminal_color_11 = c.orange
vim.g.terminal_color_12 = c.blue
vim.g.terminal_color_13 = c.magenta
vim.g.terminal_color_14 = c.cyan
vim.g.terminal_color_15 = c.fg_light

vim.o.background = 'dark'
vim.o.termguicolors = true
