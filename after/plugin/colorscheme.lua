local status, NeoSolarized = pcall(require, 'NeoSolarized')
if not status then return end

NeoSolarized.setup {
  style = 'dark',
  transparent = true,
  terminal_colors = true,
  enable_italics = false,
}

vim.cmd [[
   try
        colorscheme NeoSolarized
    catch /^Vim\%((\a\+)\)\=:E18o
        colorscheme default
        set background=dark
    endtry
]]
