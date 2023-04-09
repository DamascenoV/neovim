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
      "j-hui/fidget.nvim",
      "folke/neodev.nvim",
    }
  },
  {
    "glepnir/lspsaga.nvim",
    branch = "main",
    event = "BufRead",
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "kyazdani42/nvim-web-devicons"
    }
  },

  "akinsho/bufferline.nvim",

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
  'kdheepak/lazygit.nvim',
  'akinsho/git-conflict.nvim',

  {
    "karb94/neoscroll.nvim",
    event = "BufEnter",
    enabled = true
  },

  'jwalton512/vim-blade',
  'tpope/vim-sleuth',
  'mbbill/undotree',
  'tpope/vim-surround',
  'tpope/vim-sleuth',
  'tpope/vim-repeat',
  'norcalli/nvim-colorizer.lua',

  -- Themes
  'Tsuzat/NeoSolarized.nvim', -- Theme NeoSolarized
  'projekt0n/github-nvim-theme', -- Theme Github
  { "catppuccin/nvim", name = "catppuccin" },
  'ellisonleao/gruvbox.nvim',
  { 'tjdevries/gruvbuddy.nvim', dependencies = { 'tjdevries/colorbuddy.nvim', branch = 'dev' } },

  -- Search Projects
  { 'nvim-telescope/telescope-project.nvim' },

  -- Fuzzy Finder Algorithm which dependencies local dependencies to be built. Only load if `make` is available
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = vim.fn.executable 'make' == 1 },

  { 'junegunn/fzf', build = './install --all' },
  { 'junegunn/fzf.vim' },

  -- Tabnine
  { 'tzachar/cmp-tabnine', build = "./install.sh", dependencies = 'hrsh7th/nvim-cmp' },

  -- Git DiffView
  { 'sindrets/diffview.nvim', dependencies = 'nvim-lua/plenary.nvim' },

  -- { 'jackMort/ChatGPT.nvim',
  --   dependencies = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' }
  -- },

})
