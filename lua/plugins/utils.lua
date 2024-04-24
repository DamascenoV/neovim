return {
  {
    "mfussenegger/nvim-lint",
    event = "BufRead",
    config = function()
      require("lint").linters_by_ft = {
        php = { "phpcs" },
      }
    end,
  },

  {
    "mbbill/undotree",
    event = "BufRead",
    enabled = false
  },

  { "numToStr/Comment.nvim", config = true, event = "BufReadPre" },

  {
    "iamcco/markdown-preview.nvim",
    enabled = false,
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },

  {
    "jwalton512/vim-blade",
    enabled = false,
  },

  { "tpope/vim-sleuth", event = "BufReadPre" },

  {
    "Exafunction/codeium.vim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    config = function()
      vim.g.codeium_disable_bindings = 1
      vim.keymap.set('i', '<C-g>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
    end
  },

  {
    "stevearc/oil.nvim",
    event = "BufReadPre",
    cmd = { "Oil" },
    opts = {},
  },

  {
    "vigoux/notifier.nvim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {},
  },

  {
    "akinsho/flutter-tools.nvim",
    enabled = false,
    ft = { "dart" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = true,
  },

  {
    'nvim-tree/nvim-web-devicons',
    event = "BufReadPre",
    opts = {}
  },

  {
    'echasnovski/mini.statusline',
    version = '*',
    opts = {
      set_vim_settings = false,
    }
  },

  {
    'echasnovski/mini.surround',
    version = '*',
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {}
  },

  {
    'echasnovski/mini.pairs',
    version = '*',
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {}
  },

  {
    'echasnovski/mini.ai',
    version = '*',
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {}
  }
}
