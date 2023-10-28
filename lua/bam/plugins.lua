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
      "L3MON4D3/LuaSnip",
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

  "akinsho/bufferline.nvim",
  -- "jose-elias-alvarez/null-ls.nvim",

  { "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    }
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
  'nvim-treesitter/nvim-treesitter-context',
  { 'nvim-treesitter/playground' },
  "windwp/nvim-ts-autotag",

  { "windwp/nvim-autopairs", config = true, event = "InsertEnter" },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    }
  },

  { "numToStr/Comment.nvim", config = true, event = "BufEnter" },
  { "iamcco/markdown-preview.nvim", ft = "markdown" },
  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'lewis6991/gitsigns.nvim',
  'akinsho/git-conflict.nvim',

  -- FLUTTER
  'akinsho/flutter-tools.nvim',
  "RobertBrunhage/flutter-riverpod-snippets",
  "Neevash/awesome-flutter-snippets",

  -- Language support, mainly for indentation
  "dart-lang/dart-vim-plugin",

  'olexsmir/gopher.nvim',
  'jwalton512/vim-blade',
  'tpope/vim-sleuth',
  'mbbill/undotree',
  'tpope/vim-surround',
  'tpope/vim-sleuth',
  'tpope/vim-repeat',
  'tpope/vim-dotenv',
  { 'phaazon/hop.nvim', branch = 'v2' },
  --'norcalli/nvim-colorizer.lua',

  -- Themes
  { "catppuccin/nvim", name = "catppuccin" },
  { 'tjdevries/gruvbuddy.nvim', dependencies = { 'tjdevries/colorbuddy.nvim', branch = 'dev' } },

  -- Search Projects
  { 'nvim-telescope/telescope-project.nvim' },

  -- Fuzzy Finder Algorithm which dependencies local dependencies to be built. Only load if `make` is available
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = vim.fn.executable 'make' == 1 },

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
})
