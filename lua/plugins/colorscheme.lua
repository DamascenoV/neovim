return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 10000,
  config = function()
    require("catppuccin").setup({
      flavour = 'mocha',
      transparent_background = true,
      show_end_of_buffer = true,
      color_overrides = {
        mocha = {
          yellow = "#fbfead",
          red = "#cc6666",
          blue = "#7aa0bb",
          mauve = "#b294bb",
          lavender = "#e0e0e0",
          pink = "#e0e0e0",
          teal = "#e0e0e0",
          crust = "#e0e0e0",
          mantle = "#e0e0e0",
          rosewater = "#e0e0e0",
          green = "#b3f6c0",
          base = "#14161b",
          maroon = "#e0e0e0",
          none = "#e0e0e0",
          peach = "#d4aa55",
          flamingo = "#8f7436"
        }
      },
      integrations = {
        telescope = false,
      }
    })
    vim.cmd.colorscheme "catppuccin"
  end
}
