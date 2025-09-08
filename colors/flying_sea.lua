if vim.g.colors_name ~= nil then
  vim.cmd('highlight clear')
end
vim.g.colors_name = "flying_sea"

local colors = {
  -- Base colors
  bg = "#062628",
  fg = "#d8d4cd",

  -- Background variations
  bg_dark = "#001d1f",
  bg_light = "#244244",
  bg_lighter = "#406062",

  -- Foreground variations
  fg_dim = "#98948d",
  fg_bright = "#a6e1e5",
  fg_light = "#b8b4ad",
  fg_lighter = "#e6e2db",
  fg_lightest = "#f4f0e9",

  -- Accent colors
  red = "#f9c5ce",
  red_dark = "#38131c",

  orange = "#f6cab1",
  orange_dark = "#371702",

  yellow = "#e0d5a9",
  yellow_dark = "#312800",

  green = "#bfdfbb",
  green_dark = "#0e280b",

  cyan = "#a8e2db",
  cyan_dark = "#003934",

  blue = "#addcf5",
  blue_dark = "#002d3f",

  purple = "#cad2fd",
  purple_dark = "#1a1d3d",

  magenta = "#e8c8ed",

  -- Terminal colors
  term_black = "#001a1b",
  term_bright_black = "#406062",
  term_white = "#98948d",
  term_bright_white = "#f4f0e9",
}

-- Helper function for setting highlights
local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Core editor highlights
local function set_editor_highlights()
  hi("Normal", { bg = colors.bg, fg = colors.fg })
  hi("NormalFloat", { bg = colors.bg, fg = colors.fg })
  hi("NormalNC", { link = "Normal" })

  hi("Cursor", { bg = colors.fg, fg = colors.bg })
  hi("lCursor", { bg = colors.fg, fg = colors.bg })
  hi("TermCursorNC", { reverse = true })

  hi("CursorLine", { bg = colors.bg_light })
  hi("CursorColumn", { bg = colors.bg_light })
  hi("CursorLineNr", { bold = true, fg = colors.fg_bright })
  hi("CursorLineFold", { fg = colors.bg_lighter })
  hi("CursorLineSign", { fg = colors.bg_lighter })

  hi("LineNr", { fg = colors.bg_lighter })
  hi("SignColumn", { fg = colors.bg_lighter })
  hi("FoldColumn", { fg = colors.bg_lighter })
  hi("Folded", { bg = colors.bg_dark, fg = colors.fg_dim })

  hi("ColorColumn", { bg = colors.bg_lighter })
  hi("VertSplit", { fg = colors.fg_bright })
  hi("WinSeparator", { fg = colors.fg_bright })

  hi("Visual", { bg = colors.bg_lighter })
  hi("VisualNOS", { bg = colors.bg_light })

  hi("Pmenu", { bg = colors.bg_light, fg = colors.fg })
  hi("PmenuMatch", { bg = colors.bg_light, bold = true, fg = colors.fg })
  hi("PmenuMatchSel", { blend = 0, bold = true, reverse = true })
  hi("PmenuThumb", { bg = colors.bg_lighter })

  hi("StatusLine", { bg = colors.bg, fg = colors.fg_light })
  hi("StatusLineNC", { bg = colors.bg_dark, fg = colors.fg_light })
  hi("WinBar", { link = "StatusLine" })
  hi("WinBarNC", { link = "StatusLineNC" })

  hi("TabLine", { bg = colors.bg_dark, fg = colors.fg_light })
  hi("TabLineSel", { bg = colors.bg_dark, fg = colors.fg_bright })

  hi("FloatBorder", { bg = colors.bg, fg = colors.fg_bright })
  hi("FloatTitle", { bg = colors.bg_dark, bold = true, fg = colors.fg_bright })
end

-- Search and matching
local function set_search_highlights()
  hi("Search", { bg = colors.fg_bright, fg = colors.bg })
  hi("CurSearch", { bg = colors.yellow, fg = colors.bg })
  hi("IncSearch", { bg = colors.yellow, fg = colors.bg })
  hi("Substitute", { bg = colors.purple, fg = colors.bg })
  hi("MatchParen", { bg = colors.bg_lighter, bold = true })
end

-- Messages and notifications
local function set_message_highlights()
  hi("ModeMsg", { fg = colors.green })
  hi("MoreMsg", { fg = colors.blue })
  hi("ErrorMsg", { fg = colors.red })
  hi("WarningMsg", { fg = colors.yellow })
  hi("Question", { fg = colors.blue })
  hi("Title", { fg = colors.fg_bright })
  hi("MsgArea", { link = "Normal" })
  hi("MsgSeparator", { bg = colors.bg_lighter, fg = colors.fg_dim })
end

-- Syntax highlighting
local function set_syntax_highlights()
  hi("Comment", { fg = colors.fg_dim })
  hi("NonText", { fg = colors.orange })
  hi("SpecialKey", { fg = colors.bg_lighter })
  hi("Whitespace", { fg = colors.bg_lighter })
  hi("EndOfBuffer", { fg = colors.bg_lighter })
  hi("Conceal", { fg = colors.blue })

  -- Core syntax groups
  hi("Keyword", { fg = colors.fg })
  hi("Statement", { fg = colors.fg })
  hi("Conditional", { fg = colors.fg })
  hi("Repeat", { fg = colors.fg })
  hi("Label", { fg = colors.fg })
  hi("Operator", { fg = colors.fg })
  hi("Exception", { fg = colors.fg })

  hi("PreProc", { fg = colors.fg })
  hi("Include", { fg = "#86E08F" })
  hi("Define", { fg = "#86E08F" })
  hi("Macro", { fg = "#86E08F" })
  hi("PreCondit", { fg = colors.fg })

  hi("Type", { fg = "#8FE1C8" })
  hi("StorageClass", { fg = colors.fg })
  hi("Structure", { fg = colors.fg })
  hi("Typedef", { fg = colors.fg })

  hi("Identifier", { fg = colors.fg })
  hi("Function", { fg = "#d4d4d4" })

  hi("Constant", { fg = "#8FE1C8" })
  hi("String", { fg = colors.green })
  hi("Character", { fg = colors.orange })
  hi("Number", { fg = "#8FE1C8" })
  hi("Boolean", { fg = "#8FE1C8" })
  hi("Float", { fg = "#8FE1C8" })

  hi("Special", { fg = colors.cyan })
  hi("SpecialChar", { fg = colors.orange })
  hi("Tag", { fg = colors.orange })
  hi("Delimiter", { fg = colors.orange })

  hi("Todo", { bg = colors.bg, bold = true, fg = colors.fg_bright })
  hi("Error", { bg = colors.red_dark })
  hi("Ignore", {})

  -- Text formatting
  hi("Bold", { bold = true })
  hi("Italic", { italic = true })
end

-- Diagnostics
local function set_diagnostic_highlights()
  hi("DiagnosticError", { fg = colors.red })
  hi("DiagnosticWarn", { fg = colors.yellow })
  hi("DiagnosticInfo", { fg = colors.purple })
  hi("DiagnosticHint", { fg = colors.cyan })
  hi("DiagnosticOk", { fg = colors.green })

  hi("DiagnosticUnderlineError", { sp = colors.red, underline = true })
  hi("DiagnosticUnderlineWarn", { sp = colors.yellow, underline = true })
  hi("DiagnosticUnderlineInfo", { sp = colors.purple, underline = true })
  hi("DiagnosticUnderlineHint", { sp = colors.cyan, underline = true })
  hi("DiagnosticUnderlineOk", { sp = colors.green, underline = true })

  hi("DiagnosticFloatingError", { bg = colors.bg_dark, fg = colors.red })
  hi("DiagnosticFloatingWarn", { bg = colors.bg_dark, fg = colors.yellow })
  hi("DiagnosticFloatingInfo", { bg = colors.bg_dark, fg = colors.purple })
  hi("DiagnosticFloatingHint", { bg = colors.bg_dark, fg = colors.cyan })
  hi("DiagnosticFloatingOk", { bg = colors.bg_dark, fg = colors.green })

  hi("DiagnosticDeprecated", { sp = colors.red, strikethrough = true })
end

-- Diffs
local function set_diff_highlights()
  hi("DiffAdd", { bg = colors.green_dark })
  hi("DiffChange", { bg = colors.cyan_dark })
  hi("DiffDelete", { bg = colors.red_dark })
  hi("DiffText", { bg = colors.yellow_dark })

  hi("diffAdded", { fg = colors.green })
  hi("diffChanged", { fg = colors.cyan })
  hi("diffRemoved", { fg = colors.red })
  hi("diffFile", { fg = colors.yellow })
  hi("diffLine", { fg = colors.purple })

  hi("Added", { fg = colors.green })
  hi("Changed", { fg = colors.cyan })
  hi("Removed", { fg = colors.red })
end

-- Spell checking
local function set_spell_highlights()
  hi("SpellBad", { sp = colors.red, undercurl = true })
  hi("SpellCap", { sp = colors.cyan, undercurl = true })
  hi("SpellLocal", { sp = colors.yellow, undercurl = true })
  hi("SpellRare", { sp = colors.purple, undercurl = true })
end

-- TreeSitter highlights
local function set_treesitter_highlights()
  -- Variables and identifiers
  hi("@variable", { fg = colors.fg })
  hi("@variable.builtin", { link = "Special" })
  hi("@variable.member", { link = "@field" })
  hi("@variable.parameter", { link = "@parameter" })

  hi("@constant", { link = "Constant" })
  hi("@constant.builtin", { link = "Special" })
  hi("@constant.macro", { link = "Macro" })

  hi("@parameter", { fg = colors.purple })
  hi("@field", { link = "Identifier" })
  hi("@namespace", { link = "Identifier" })
  hi("@module", { link = "@namespace" })
  hi("@module.builtin", { link = "@variable.builtin" })

  -- Functions
  hi("@function", { fg = colors.fg_lightest })
  hi("@function.builtin", { link = "Special" })
  hi("@function.call", { link = "Function" })
  hi("@function.macro", { link = "Macro" })
  hi("@function.method", { link = "@method" })
  hi("@function.method.call", { link = "@method.call" })
  hi("@method", { link = "Function" })
  hi("@method.call", { link = "Function" })

  -- Types
  hi("@type", { fg = "#8FE1C8" })
  hi("@type.builtin", { link = "Special" })
  hi("@type.definition", { link = "Typedef" })
  hi("@type.qualifier", { link = "StorageClass" })
  hi("@structure", { link = "Structure" })

  -- Keywords
  hi("@keyword", { fg = colors.fg })
  hi("@keyword.conditional", { link = "@keyword" })
  hi("@keyword.conditional.ternary", { link = "Keyword" })
  hi("@keyword.coroutine", { link = "@keyword" })
  hi("@keyword.debug", { bold = true, fg = colors.cyan })
  hi("@keyword.directive", { bold = true, fg = colors.purple })
  hi("@keyword.directive.define", { link = "@keyword.directive" })
  hi("@keyword.exception", { link = "@keyword" })
  hi("@keyword.function", { link = "@keyword" })
  hi("@keyword.import", { bold = true, fg = colors.purple })
  hi("@keyword.operator", { link = "@keyword" })
  hi("@keyword.repeat", { link = "@keyword" })
  hi("@keyword.return", { bold = true, fg = colors.orange })
  hi("@keyword.storage", { bold = true, fg = colors.fg })

  -- Operators and punctuation
  hi("@operator", { fg = "#FFFFFF" })
  hi("@punctuation", { link = "Delimiter" })
  hi("@punctuation.bracket", { link = "@punctuation" })
  hi("@punctuation.delimiter", { link = "@punctuation" })
  hi("@punctuation.special", { link = "Special" })

  -- Numbers and literals
  hi("@number", { fg = "#8FE1C8" })
  hi("@number.float", { link = "@float" })
  hi("@float", { link = "Constant" })

  -- Strings
  hi("@string", { link = "String" })
  hi("@string.documentation", { link = "@string" })
  hi("@string.escape", { link = "SpecialChar" })
  hi("@string.regexp", { link = "SpecialChar" })
  hi("@string.special", { link = "SpecialChar" })
  hi("@string.special.path", { link = "Directory" })
  hi("@string.special.symbol", { link = "@constant" })
  hi("@string.special.url", { link = "@markup.link.url" })
  hi("@string.special.vimdoc", { link = "@constant" })

  -- Includes and imports
  hi("@include", { fg = "#86E08F" })

  -- Comments
  hi("@comment", { link = "Comment" })
  hi("@comment.documentation", { link = "@comment" })
  hi("@comment.error", { link = "@text.danger" })
  hi("@comment.note", { link = "@text.note" })
  hi("@comment.todo", { link = "@text.todo" })
  hi("@comment.warning", { link = "@text.warning" })

  -- Control flow
  hi("@conditional", { link = "Conditional" })
  hi("@repeat", { link = "Repeat" })
  hi("@exception", { link = "Exception" })

  -- Preprocessor
  hi("@preproc", { link = "PreProc" })
  hi("@define", { link = "Define" })
  hi("@debug", { link = "Debug" })
  hi("@macro", { link = "Macro" })

  -- Storage classes
  hi("@storageclass", { link = "StorageClass" })

  -- Special identifiers
  hi("@symbol", { link = "Keyword" })
  hi("@character.special", { link = "SpecialChar" })
end

-- Markup (markdown, etc)
local function set_markup_highlights()
  -- Text formatting
  hi("@text.emphasis", { italic = true })
  hi("@text.strong", { bold = true })
  hi("@text.underline", { link = "Underlined" })
  hi("@text.strike", { strikethrough = true })

  -- Links and references
  hi("@text.reference", { link = "Identifier" })
  hi("@text.uri", { link = "Underlined" })
  hi("@markup.link", { link = "@text.reference" })
  hi("@markup.link.label", { link = "@markup.link" })
  hi("@markup.link.url", { fg = colors.fg, underline = true })

  -- Code blocks
  hi("@text.literal", { link = "Special" })
  hi("@markup.raw", { link = "@text.literal" })
  hi("@markup.raw.block", { link = "@markup.raw" })

  -- Headings
  hi("@text.title", { link = "Title" })
  hi("@markup.heading", { link = "@text.title" })
  hi("@markup.heading.1", { fg = colors.orange })
  hi("@markup.heading.2", { fg = colors.yellow })
  hi("@markup.heading.3", { fg = colors.green })
  hi("@markup.heading.4", { fg = colors.cyan })
  hi("@markup.heading.5", { fg = colors.blue })
  hi("@markup.heading.6", { fg = colors.purple })

  -- Lists
  hi("@markup.list", { link = "@punctuation.special" })
  hi("@markup.list.checked", { link = "DiagnosticOk" })
  hi("@markup.list.unchecked", { link = "DiagnosticWarn" })

  -- Other markup elements
  hi("@markup.italic", { link = "@text.emphasis" })
  hi("@markup.strong", { link = "@text.strong" })
  hi("@markup.underline", { link = "@text.underline" })
  hi("@markup.strikethrough", { link = "@text.strike" })
  hi("@markup.math", { link = "@string.special" })
  hi("@markup.quote", { link = "@string.special" })
  hi("@markup.environment", { link = "@module" })

  -- Status indicators
  hi("@text.todo", { link = "Todo" })
  hi("@text.note", { link = "MoreMsg" })
  hi("@text.warning", { link = "WarningMsg" })
  hi("@text.danger", { link = "ErrorMsg" })
end

-- LSP highlights
local function set_lsp_highlights()
  hi("LspReferenceText", { bg = colors.bg_lighter })
  hi("LspSignatureActiveParameter", { link = "LspReferenceText" })
  hi("LspCodeLens", { link = "Comment" })
  hi("LspCodeLensSeparator", { link = "Comment" })

  -- LSP semantic tokens
  hi("@lsp.type.class", { link = "@structure" })
  hi("@lsp.type.decorator", { link = "@function" })
  hi("@lsp.type.enum", { link = "@type" })
  hi("@lsp.type.enumMember", { link = "@constant" })
  hi("@lsp.type.function", { link = "@function" })
  hi("@lsp.type.interface", { link = "@type" })
  hi("@lsp.type.macro", { link = "@macro" })
  hi("@lsp.type.method", { link = "@method" })
  hi("@lsp.type.namespace", { link = "@namespace" })
  hi("@lsp.type.parameter", { link = "@parameter" })
  hi("@lsp.type.property", { link = "@property" })
  hi("@lsp.type.struct", { link = "@structure" })
  hi("@lsp.type.type", { link = "@type" })
  hi("@lsp.type.typeParameter", { link = "@type.definition" })
  hi("@lsp.type.variable", { link = "@variable" })

  hi("@lsp.mod.deprecated", { fg = colors.red })
end

-- Git highlights
local function set_git_highlights()
  hi("GitSignsAdd", { fg = colors.green })
  hi("GitSignsChange", { fg = colors.yellow })
  hi("GitSignsDelete", { fg = colors.red })
  hi("GitSignsUntracked", { fg = colors.blue })

  hi("GitSignsAddInline", { link = "GitSignsAdd" })
  hi("GitSignsChangeInline", { link = "GitSignsChange" })
  hi("GitSignsDeleteInline", { link = "GitSignsDelete" })
  hi("GitSignsUntrackedInline", { link = "GitSignsUntracked" })

  hi("GitSignsAddLn", { link = "GitSignsAdd" })
  hi("GitSignsChangeLn", { link = "GitSignsChange" })
  hi("GitSignsDeleteLn", { link = "GitSignsDelete" })
  hi("GitSignsUntrackedLn", { link = "GitSignsUntracked" })
end

-- Plugin-specific highlights (keeping only the most common ones)
local function set_plugin_highlights()
  -- Telescope
  hi("TelescopeBorder", { fg = colors.fg_bright })
  hi("TelescopeMatching", { bold = true })
  hi("TelescopeSelection", { bg = colors.bg_light })
  hi("TelescopeMultiSelection", { bg = colors.bg_lighter })

  -- NvimTree
  hi("NvimTreeRootFolder", { bold = true, fg = colors.fg_bright })
  hi("NvimTreeFolderIcon", { fg = colors.fg_dim })
  hi("NvimTreeIndentMarker", { link = "NvimTreeFolderIcon" })
  hi("NvimTreeExecFile", { bold = true, fg = colors.green })
  hi("NvimTreeSpecialFile", { fg = colors.fg_bright, underline = true })
  hi("NvimTreeSymlink", { bold = true, fg = colors.purple })
  hi("NvimTreeImageFile", { fg = colors.orange })
  hi("NvimTreeOpenedFile", { link = "NvimTreeExecFile" })

  hi("NvimTreeGitStaged", { fg = colors.green })
  hi("NvimTreeGitDirty", { fg = colors.yellow })
  hi("NvimTreeGitDeleted", { fg = colors.red })
  hi("NvimTreeGitNew", { fg = colors.cyan })
  hi("NvimTreeGitRenamed", { fg = colors.magenta })
  hi("NvimTreeGitMerge", { fg = colors.orange })

  hi("NvimTreeWindowPicker", { bg = colors.bg_lighter, bold = true, fg = colors.fg })

  -- Directory highlighting
  hi("Directory", { fg = colors.blue })

  hi("MiniDiffSignAdd", { fg = colors.green })
  hi("MiniDiffSignChange", { fg = colors.yellow })
  hi("MiniDiffSignDelete", { fg = colors.red })
  hi("MiniDiffOverAdded", { bg = colors.green_dark })
  hi("MiniDiffOverChanged", { bg = colors.cyan_dark })
  hi("MiniDiffOverDeleted", { bg = colors.red_dark })
end

-- Terminal colors
local function set_terminal_colors()
  local g = vim.g
  g.terminal_color_0 = colors.term_black
  g.terminal_color_1 = colors.red
  g.terminal_color_2 = colors.green
  g.terminal_color_3 = colors.yellow
  g.terminal_color_4 = colors.blue
  g.terminal_color_5 = colors.magenta
  g.terminal_color_6 = colors.cyan
  g.terminal_color_7 = colors.term_white
  g.terminal_color_8 = colors.term_bright_black
  g.terminal_color_9 = colors.red
  g.terminal_color_10 = colors.green
  g.terminal_color_11 = colors.yellow
  g.terminal_color_12 = colors.blue
  g.terminal_color_13 = colors.magenta
  g.terminal_color_14 = colors.cyan
  g.terminal_color_15 = colors.term_bright_white
end

-- Apply all highlights
set_editor_highlights()
set_search_highlights()
set_message_highlights()
set_syntax_highlights()
set_diagnostic_highlights()
set_diff_highlights()
set_spell_highlights()
set_treesitter_highlights()
set_markup_highlights()
set_lsp_highlights()
set_git_highlights()
set_plugin_highlights()
set_terminal_colors()
