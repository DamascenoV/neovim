require('github-theme').setup({
    groups = {
        all = {
            ["@variable"] = { fg = "#e0e0e0", style = {} },
            ["@variable.builtin"] = { fg = "#b294bb", style = {} },
            ["@field"] = { fg = "#e0e0e0", style = {} },
            ["@property"] = { fg = "#a3bbcf", style = {} },
            ["@type"] = { fg = "#cc6666", style = {} },
            ["@type.builtin"] = { fg = "#cc6666", style = {} },
            ["@parameter"] = { fg = "#cc6666", style = {} },
            ["@parameter.go"] = { fg = "#e0e0e0", style = {} },
            ['@statement'] = { fg = "#bf4040" },
            ["@namespace"] = { fg = "#a3bbcf", style = {} },
            ["@include"] = { fg = "#8abeb7", style = {} },
            ['@function.builtin'] = { fg = "#a3bbcf", style = {} },
            ['@constant.builtin'] = { fg = "#a992cd", style = {} },
            ['@constructor'] = { fg = "Orange", style = {} },
            ['@method'] = { fg = "#f8fe7a", style = {} },
            ['@method.call'] = { fg = "#f8fe7a", style = {} },
            ['@exception'] = { fg = "#bf4040", style = {} },
            ['@keyword.return'] = { fg = "#bf4040", style = {} },
            -- ["@operator"] = { fg = "#cc6666", style = {} },
            ["@symbol"] = { fg = "#8abeb7", style = {} },
            ['Special'] = { fg = "#a992cd", style = {} },
            ['Structure'] = { fg = "#b294bb", style = {} },
            ['Type'] = { fg = "#b294bb", style = {} },
            ['Conditional'] = { fg = "#cc6666", style = {} },
            ['Statement'] = { fg = "#bf4040", style = {} },
            ['Keyword'] = { fg = "#b294bb", style = {} },
            -- ['Operator'] = { fg = "#e6b3b3", style = {} },
            ['Identifier'] = { fg = "#cc6666", style = {} },
            ['String'] = { fg = "#99cc99", style = {} },
            ['Error'] = { fg = "#d98c8c", style = {} },
            ['WinSeparator'] = { fg = "#e0e0e0", style = {} },
        }
    },
})

vim.cmd("colorscheme github_dark_default")
