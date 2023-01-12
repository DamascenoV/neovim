return {
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      'j-hui/fidget.nvim',

      -- Additional lua configuration, makes nvim stuff amazing
      'folke/neodev.nvim',
    },
  },

  {
    'glepnir/lspsaga.nvim',
    branch = "main",
    config = function()
        local saga = require("lspsaga")
        saga.init_lsp_saga()
    end,
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
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

  {
    'akinsho/bufferline.nvim',
    config = function ()
      require('bufferline').setup{}
    end
  },

  {
    "rcarriga/nvim-notify",
    lazy = false
  },

-- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'lewis6991/gitsigns.nvim',
  'Tsuzat/NeoSolarized.nvim', -- Theme NeoSolarized
  'navarasu/onedark.nvim', -- Theme inspired by Atom
  'lukas-reineke/indent-blankline.nvim', -- Add indentation guides even on blank lines
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  'jose-elias-alvarez/null-ls.nvim', -- configure formatters & linters
  'jayp0521/mason-null-ls.nvim', -- bridges gap b/w mason & null-ls
  'mbbill/undotree', -- Three of Undo
  'windwp/nvim-autopairs', -- Auto pairs
  'karb94/neoscroll.nvim', -- Smooth scrolling
  'nvim-lualine/lualine.nvim', -- Fancier statusline
  'numToStr/Comment.nvim', -- "gc" to comment visual regions/lines
  'windwp/nvim-ts-autotag',
  'tpope/vim-surround',

-- Completion
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-nvim-lua',
  'hrsh7th/cmp-cmdline',
  'onsails/lspkind-nvim',

  -- Fuzzy Finder (files, lsp, etc)
  { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },

  -- Search Projects
  { 'nvim-telescope/telescope-project.nvim' },

  -- Fuzzy Finder Algorithm which dependencies local dependencies to be built. Only load if `make` is available
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = vim.fn.executable 'make' == 1 },

  -- Tabnine
  { 'codota/tabnine-nvim', build = "./dl_binaries.sh" },

  -- Git DiffView
  { 'sindrets/diffview.nvim', dependencies = 'nvim-lua/plenary.nvim' },
}

