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
    "Exafunction/codeium.vim",
    enabled = false,
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
    'echasnovski/mini.ai',
    version = '*',
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {}
  },

  {
    'echasnovski/mini.notify',
    version = '*',
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {}
  },
}
