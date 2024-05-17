return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { hl = "GitSignsAdd", text = "│", numhl = "GitSignsAddNr" },
          change = { hl = "GitSignsChange", text = "│", numhl = "GitSignsChangeNr" },
          delete = { hl = "GitSignsDelete", text = "_", numhl = "GitSignsDeleteNr" },
          topdelete = { hl = "GitSignsDelete", text = "‾", numhl = "GitSignsDeleteNr" },
          changedelete = { hl = "GitSignsDelete", text = "~", numhl = "GitSignsChangeNr" },
          untracked = { text = " " },
        },
        numhl = true,
        linehl = false,
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
          delay = 750,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      })
    end,
  },
  {
    "tpope/vim-fugitive",
    event = "BufReadPre",
    cmd = { "Git", "G" },
  }
}
