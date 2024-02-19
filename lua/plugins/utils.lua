return {
  { "christoomey/vim-tmux-navigator", event = "VeryLazy" },

  {
    "mfussenegger/nvim-lint",
    event = "BufRead",
    config = function()
      require("lint").linters_by_ft = {
        php = {"phpcs"}
      }
    end
  },

  {
    "mbbill/undotree",
    event = "BufRead",
  },

  { "windwp/nvim-autopairs", event = "InsertEnter", opts={} },

  { "numToStr/Comment.nvim", config = true, event = "BufEnter" },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },

  {
    'jwalton512/vim-blade',
    ft = { 'blade.php' }
  },

  { 'tpope/vim-repeat', event = "BufReadPre" },

  { 'tpope/vim-sleuth', event = "BufReadPre" },

  { 'Exafunction/codeium.vim', event = "InsertEnter" },
}
