return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 10000,
  config = function ()
    require("catppuccin").setup({
      flavour = 'frappe',
      transparent_background = true,
      show_end_of_buffer = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        telescope = true,
        treesitter = true
      },
    })
    vim.cmd.colorscheme "catppuccin"
  end
}
