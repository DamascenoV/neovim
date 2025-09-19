MiniDeps.later(function()
  MiniDeps.add({
    source = 'nvim-treesitter/nvim-treesitter',
    hooks = {post_checkout = function() vim.cmd('TSUpdate') end,},
  })

  require('nvim-treesitter.configs').setup({
    ensure_installed = {
      'go',
      'lua',
      'typescript',
      'javascript',
      'css',
      'vim',
      'php',
      'vue',
      'markdown',
      'markdown_inline',
      'elixir',
      'heex',
      'zig',
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
        node_decremental = '<c-y>',
      },
    },
  })
end)
