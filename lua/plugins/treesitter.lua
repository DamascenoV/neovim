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

  local new_autocmd = function(event, pattern, callback, desc)
    local opts = { pattern = pattern, callback = callback, desc = desc }
    vim.api.nvim_create_autocmd(event, opts)
  end

  local filetypes = vim.iter(languages):map(vim.treesitter.language.get_filetypes):flatten():totable()
  local ts_start = function(ev) vim.treesitter.start(ev.buf) end
  new_autocmd('FileType', filetypes, ts_start, 'Ensure enabled tree-sitter')
end)
