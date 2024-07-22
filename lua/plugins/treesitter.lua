return {
  'nvim-treesitter/nvim-treesitter',
  build = ":TSUpdate",
  config = function()
    require('nvim-treesitter.configs').setup {
      ensure_installed = {
        'go',
        'lua',
        'typescript',
        'vim',
        'php',
        'vue',
        'markdown',
        'markdown_inline',
        'elixir',
        'heex'
      },
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-p>',
          node_incremental = '<c-p>',
          scope_incremental = '<c-s>',
          node_decremental = '<c-backspace>',
        },
      },
    }

    -- For Work with Flex
    vim.filetype.add {
      extension = {
        pfxml = 'pfxml',
      },
    }

    vim.treesitter.language.register('php', { 'pfxml', 'blade', 'blade.php' })

    vim.cmd [[highlight IncludedC guibg=#373b41]]
  end
}
