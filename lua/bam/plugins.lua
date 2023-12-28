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
      {
        "j-hui/fidget.nvim",
        event = "LspAttach",
        tag = "legacy",
      },
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

  { "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    lazy = true
  },
  { "lukas-reineke/indent-blankline.nvim", event = "BufEnter" },

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

  { "windwp/nvim-autopairs", config = true, event = "InsertEnter" },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    lazy = true
  },

  { "numToStr/Comment.nvim", config = true, event = "BufEnter" },
  { "iamcco/markdown-preview.nvim", ft = "markdown", lazy = true },
  -- Git related plugins
  { 'tpope/vim-fugitive' },
  { 'tpope/vim-rhubarb' },
  { 'lewis6991/gitsigns.nvim' },
  { 'akinsho/git-conflict.nvim', lazy = true},

  'jwalton512/vim-blade',
  'tpope/vim-sleuth',
  'mbbill/undotree',
  'tpope/vim-surround',
  'tpope/vim-sleuth',
  'tpope/vim-repeat',
  'tpope/vim-dotenv',
  { 'phaazon/hop.nvim', branch = 'v2' },

  -- Themes
  { "catppuccin/nvim", name = "catppuccin", lazy=true },
  { 'tjdevries/gruvbuddy.nvim', dependencies = { 'tjdevries/colorbuddy.nvim', branch = 'dev' } },

  -- Search Projects
  { 'nvim-telescope/telescope-project.nvim' },

  { 'nvim-telescope/telescope-ui-select.nvim' },

  -- Git DiffView
  { 'sindrets/diffview.nvim', dependencies = 'nvim-lua/plenary.nvim' },

  -- Codeium
  { 'Exafunction/codeium.vim' },
  { 'ThePrimeagen/harpoon' },
  'rcarriga/nvim-notify',

  {
   "sourcegraph/sg.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    build = "nvim -l build/init.lua",
  },

  -- Database
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      'tpope/vim-dadbod',
      'kristijanhusak/vim-dadbod-completion'
    }
  },
  'christoomey/vim-tmux-navigator',

  -- Ocaml Stuff
  -- NOTE : Requires Ocaml, If you want to use it you need to install (and discomment the following) 
  -- -> after/plugin/ocaml.lua
  -- {
  --   'tjdevries/ocaml.nvim',
  --   lazy = true,
  --   ft = "ocaml",
  --   config = function()
  --     require("ocaml").update()
  --   end
  -- },
})
