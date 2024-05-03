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
          mauve = "#b294bb",
          none = "#e0e0e0",
          text = "#e0e0e0",
          -- lavender = "#f2e5bc",
          peach = "#de935f",
          blue = "#81a2be",
          sapphire = "#8abeb7"
        }
      },
      integrations = {
        telescope = false,
      }
    })
    vim.cmd.colorscheme "catppuccin"
  end
}
