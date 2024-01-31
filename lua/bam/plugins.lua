local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local status, lazy = pcall(require, 'lazy')
if not status then return end

lazy.setup({
  -- LSP
  {
    "VonHeikemen/lsp-zero.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "onsails/lspkind.nvim",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp"
      },
      "rafamadriz/friendly-snippets",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-cmdline",
      "folke/neodev.nvim",
    }
  },
  {
    "glepnir/lspsaga.nvim",
    branch = "main",
    event = "BufRead",
  },
  { "mfussenegger/nvim-lint" },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "kyazdani42/nvim-web-devicons"
    }
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    }
  },
  "windwp/nvim-ts-autotag",

  { "windwp/nvim-autopairs", event = "InsertEnter", opts={} },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    lazy = true
  },

  { "numToStr/Comment.nvim", config = true, event = "BufEnter" },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" }
  },
  -- Git related plugins
  { 'tpope/vim-fugitive' },
  { 'tpope/vim-rhubarb' },
  { 'lewis6991/gitsigns.nvim' },

  {
    'jwalton512/vim-blade',
    ft = { 'blade.php' }
  },
  'mbbill/undotree',
  'tpope/vim-surround',
  'tpope/vim-sleuth',
  'tpope/vim-repeat',
  'tpope/vim-dotenv',
  { 'phaazon/hop.nvim', branch = 'v2', event = "VeryLazy" },


  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    }
  },

  { 'projekt0n/github-nvim-theme', lazy = true },

  { 'nvim-telescope/telescope-ui-select.nvim' },

  -- Codeium
  { 'Exafunction/codeium.vim', event = "InsertEnter" },
  { 'ThePrimeagen/harpoon' },
  'rcarriga/nvim-notify',

  -- {
  --  "sourcegraph/sg.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   build = "nvim -l build/init.lua",
  --   enabled = false
  -- },

  -- Database
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      'tpope/vim-dadbod',
      'kristijanhusak/vim-dadbod-completion'
    }
  },
  'christoomey/vim-tmux-navigator',
  'gleam-lang/gleam.vim',

  'stevearc/oil.nvim',
  -- Ocaml Stuff
  -- NOTE : Requires Ocaml, If you want to use it you need to install (and discomment the following) 
  -- -> after/plugin/ocaml.lua
  -- {
  --   'tjdevries/ocaml.nvim',
  --   event = "VeryLazy",
  --   lazy = true,
  --   ft = "ocaml",
  --   -- config = function()
  --   --   require("ocaml").update()
  --   -- end
  -- },
})
