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
    "elixir-tools/elixir-tools.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local elixir = require("elixir")
      local elixirls = require("elixir.elixirls")

      elixir.setup({
        nextls = { enable = true },
        credo = {},
        elixirls = {
          enable = true,
          settings = elixirls.settings({
            dialyzerEnabled = false,
            enableTestLenses = false,
          }),
        },
        dependencies = {
          "nvim-lua/plenary.nvim",
        },
      })
    end,
  },

  {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = true,
  },
}
