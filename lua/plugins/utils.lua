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

  { "tpope/vim-sleuth", event = "BufReadPre" },

  {
    "stevearc/oil.nvim",
    event = "BufReadPre",
    cmd = { "Oil" },
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
    'echasnovski/mini.statusline',
    version = false,
    opts = {
      set_vim_settings = false
    }
  },

  {
    'echasnovski/mini.icons',
    version = false,
    event = "BufReadPre",
    opts = {}
  },

  {
    'echasnovski/mini.surround',
    version = false,
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {}
  },

  {
    'echasnovski/mini.ai',
    version = false,
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {}
  },

  {
    'echasnovski/mini.notify',
    version = false,
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {}
  },

  {
    'echasnovski/mini.jump2d',
    version = false,
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {}
  },

  {
    'ibhagwan/fzf-lua',
    event = "BufReadPre",
    dependencies = {
      'echasnovski/mini.icons',
    },
    cmd ={ "FzfLua" },
  },
}
