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
  },

  {
    "windwp/nvim-autopairs",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {},
  },

  { "numToStr/Comment.nvim", config = true, event = "BufReadPre" },

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
    "jwalton512/vim-blade",
    ft = { "blade.php" },
  },

  { "tpope/vim-sleuth", event = "BufReadPre" },

  {
    "Exafunction/codeium.vim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    config = function ()
      vim.g.codeium_disable_bindings = 1
      vim.keymap.set('i', '<C-g>', function () return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
    end
  },

  {
    "stevearc/oil.nvim",
    opts = {},
  },

  {
    "vigoux/notifier.nvim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {},
  },

  {
    "akinsho/flutter-tools.nvim",
    -- lazy = false,
    ft = { "dart" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = true,
  },

  {
    'echasnovski/mini.animate',
    version = '*',
    opts = {
      cursor = {
        enable = false,
      },
    }
  },

}
