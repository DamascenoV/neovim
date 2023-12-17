require 'mellifluous'.setup({
    color_set = 'alduin',
    transparent_background = {
        enabled = true,
        file_tree = false,
        cursor_line = false
    },
    plugins = {
        telescope = {
            nvchad_like = false
        }
    },
    alduin = {
        color_overrides = {
            dark = {
                strings = '#99cc99',
                fg = '#e0e0e0',
            }
        }
    }
})

vim.cmd('colorscheme mellifluous')
