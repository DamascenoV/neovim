return {
  cmd = { 'emmylua_ls' },
  filetypes = { 'lua' },
  root_markers = { '.emmyrc.json', '.luarc.json', '.git' },
  settings = {
    emmylua = {
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        library = {
          vim.env.VIMRUNTIME,
          vim.api.nvim_get_runtime_file('lua/lspconfig', false)[1],
        },
      },
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
}
