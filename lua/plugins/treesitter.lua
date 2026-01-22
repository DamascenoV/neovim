MiniDeps.later(function()
  MiniDeps.add({
    source = 'nvim-treesitter/nvim-treesitter',
    checkout = 'main',
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end, },
  })

  local languages = {
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
  }

  require('nvim-treesitter').install(languages)

  local filetypes = vim.iter(languages):map(vim.treesitter.language.get_filetypes):flatten():totable()

  vim.api.nvim_create_autocmd(
    'FileType',
    {
      pattern = filetypes,
      callback = function(ev) vim.treesitter.start(ev.buf) end,
      desc = 'Ensure enabled tree-sitter'
    }
  )
end)
