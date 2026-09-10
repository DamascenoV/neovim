local add = vim.pack.add
local now_if_args, later = Config.now_if_args, Config.later

now_if_args(function()
  local ts_update = function() vim.cmd('TSUpdate') end
  Config.on_packchanged('nvim-treesitter', { 'update' }, ts_update, ':TSUpdate')

  add({
    'https://github.com/nvim-treesitter/nvim-treesitter',
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

  vim.api.nvim_create_autocmd('FileType', {
    pattern = filetypes,
    callback = function(ev)
      vim.treesitter.start(ev.buf)
      vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
    end,
    desc = 'Ensure enabled tree-sitter',
  })
end)
