return {
  {
    'mfussenegger/nvim-lint',
    event = "BufReadPre",
    config = function()
      require('lint').linters_by_ft = {
        -- php = { 'phpcs' },
      }
    end
  },

  { "tpope/vim-sleuth", event = "BufReadPre" },

  -- {
  --   'ibhagwan/fzf-lua',
  --   event = "BufReadPre",
  --   cmd = { "FzfLua" },
  --   config = function()
  --     require("fzf-lua").setup({ keymap = { builtin = { true, ["<C-c>"] = "hide" } } })
  --   end
  -- },

  {
    "sphamba/smear-cursor.nvim",
    opts = {},
  },

  {
    'kristijanhusak/vim-dadbod-ui',
    event = "BufReadPre",
    dependencies = {
      { 'tpope/vim-dadbod', lazy = true },
    },
    cmd = { 'DBUI' }
  },
}
