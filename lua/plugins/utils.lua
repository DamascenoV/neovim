return {
  { "christoomey/vim-tmux-navigator", event = "VeryLazy" },

  { "mfussenegger/nvim-lint", event = "BufReadPre" },

  {
    "mbbill/undotree",
    event = "VeryLazy",
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

  { 'phaazon/hop.nvim', branch = 'v2', event = "VeryLazy" },

  { 'Exafunction/codeium.vim', event = "InsertEnter" },
}
