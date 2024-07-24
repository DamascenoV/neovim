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
    "MagicDuck/grug-far.nvim",
    event = "BufReadPre",
    opts = {}
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
    'echasnovski/mini.statusline',
    version = false,
    opts = {
      set_vim_settings = false,
    }
  },

  {
    'echasnovski/mini.icons',
    event = "BufReadPre",
    opts = {}
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

  {
    'echasnovski/mini.pick',
    version = false,
    event = "BufReadPre",
    cmd = { "Pick" },
    opts = {
      window = {
        config = function()
          local height = math.floor(0.618 * vim.o.lines)
          local width = math.floor(0.618 * vim.o.columns)
          return {
            anchor = 'NW',
            height = height,
            width = width,
            row = math.floor(0.5 * (vim.o.lines - height)),
            col = math.floor(0.5 * (vim.o.columns - width)),
          }
        end
      }
    }
  },

  {
    'echasnovski/mini.extra',
    version = false,
    opts = {}
  },
}
