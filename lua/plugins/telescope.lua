return {
  "nvim-telescope/telescope.nvim",
  dependencies = { 'nvim-lua/plenary.nvim' },
  event = "VeryLazy",
  config = function()
    local actions = require("telescope.actions")
    require("telescope").setup({
      defaults = {
        mappings = {
          i = {
            ["<C-u>"] = false,
            ["<C-d>"] = actions.delete_buffer,
          },
          n = {
            ["<C-d>"] = actions.delete_buffer,
            ["<C-c>"] = actions.close,
            ["<C-k>"] = actions.preview_scrolling_up,
            ["<C-j>"] = actions.preview_scrolling_down,
          },
        },
      },
      pickers = {
        colorscheme = {
          enable_preview = true,
        },
      },
    })
  end,
}
