return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 10000,
  config = function ()
    require("catppuccin").setup({
      flavour = 'macchiato',
      transparent_background = true,
      show_end_of_buffer = true,
    })
    vim.cmd.colorscheme "catppuccin"
  end
}
