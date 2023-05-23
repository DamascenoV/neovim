require("catppuccin").setup({
    flavour = "frappe", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "latte",
        dark = "mocha",
    },
    transparent_background = true,
    show_end_of_buffer = false, -- show the '~' characters after the end of buffers
    term_colors = false,
    dim_inactive = {
        enabled = false,
        shade = "dark",
        percentage = 0.15,
    },
    no_italic = false, -- Force no italic
    no_bold = false, -- Force no bold
    styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
    },
    color_overrides = {},
    custom_highlights = function(colors)
        return {
            ["@variable"] = { fg = "#e0e0e0", style = {} },
            ["@variable.builtin"] = { fg = "#b294bb", style = {} },
            ["@field"] = { fg = "#e0e0e0", style = {} },
            ["@property"] = { fg = "#e0e0e0", style = {} },
            ["@type"] = { fg = "#cc6666", style = {} },
            ["@type.builtin"] = { fg = "#cc6666", style = {} },
            ["@parameter"] = { fg = "#cc6666", style = {} },
            ['@statement'] = { fg = "#bf4040"},
            ["@namespace"] = { fg = "#a3bbcf", style = {} },
            ["@include"] = { fg = "#8abeb7", style = {} },
            ["@comment"] = { fg = colors.surface2, style = { "italic" } },
            ['@function'] = { fg = "#f8fe7a", style = {} },
            ['@function.builtin'] = { fg = "#a3bbcf", style = {} },
            ['@function.call'] = { fg = "#f8fe7a", style = {} },
            ['@constant.builtin'] = { fg = "#a992cd", style = {} },
            ['@method'] = { fg = "#f8fe7a", style = {} },
            ['@method.call'] = { fg = "#f8fe7a", style = {} },
            ['@exception'] = { fg = "#bf4040", style = {} },
            ['@keyword.return'] = { fg = "#bf4040", style = {} },
            ['DiagnosticError'] = { fg = "#cc6666", style = {} },
            ['DiagnosticWarn'] = { fg = "Orange", style = {} },
            ['DiagnosticInfo'] = { fg = "LightBlue", style = {} },
            ['DiagnosticHint'] = { fg = "LightGray", style = {} },
            ['DiagnosticOk'] = { fg = "LightGreen", style = {} },
            ['Special'] = { fg = "#a992cd", style = {} },
            ['Structure'] = { fg = "#b294bb", style = {} },
            ['Type'] = { fg = "#b294bb", style = {} },
            ['Conditional'] = { fg = "#cc6666", style = {} },
            ['Statement'] = { fg = "#bf4040", style = {} },
            ['Keyword'] = { fg = "#b294bb", style = {} },
            ['Operator'] = { fg = "#e6b3b3", style = {} },
            ['Identifier'] = { fg = "#cc6666", style = {} },
            ['String'] = { fg = "#99cc99", style = {} },
            ['Error'] = { fg = "#d98c8c", style = {} },
        }
    end,
    integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = true,
        notify = false,
        mini = false,
    },
})

vim.cmd.colorscheme "catppuccin"
