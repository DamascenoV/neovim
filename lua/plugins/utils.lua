return {
  {
    'mfussenegger/nvim-lint',
    event = "BufReadPre",
    config = function()
      require('lint').linters_by_ft = {
        php = { 'phpcs' },
      }
    end
  },

  { "tpope/vim-sleuth", event = "BufReadPre" },

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
    opts = {},
    config = function()
      require('mini.icons').tweak_lsp_kind()
    end
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
    opts = {},
    config = function()
      vim.notify = require('mini.notify').make_notify()
    end
  },

  {
    'echasnovski/mini-git',
    version = false,
    event = "BufReadPre",
    config = function()
      require('mini.git').setup()
    end
  },

  {
    'echasnovski/mini.diff',
    version = false,
    event = "BufReadPre",
    opts = {}
  },

  {
    'echasnovski/mini.completion',
    version = false,
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {
      window = {
        info = { height = 25, width = 80, border = 'rounded' },
        signature = { height = 25, width = 80, border = 'rounded' },
      },
    },
  },

  {
    "echasnovski/mini.files",
    version = false,
    event = "BufReadPre",
    opts = {
      mappings = {
        close = '<C-c>',
        go_in = 'l',
        go_in_plus = '<CR>',
        go_out = 'h',
        go_out_plus = '-'
      },
      windows = {
        max_number = 1,
        width_focus = 100
      }
    },
  },

  {
    'ibhagwan/fzf-lua',
    event = "BufReadPre",
    dependencies = {
      'echasnovski/mini.icons',
    },
    cmd = { "FzfLua" },
  },
}
