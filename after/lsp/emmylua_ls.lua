return {
  cmd = { 'emmylua_ls' },
  filetypes = { 'lua' },
  root_markers = { '.emmyrc.json', '.luarc.json', '.git' },
  settings = {
    runtime = {
      version = 'LuaJIT',
    },
    workspace = {
      library = vim.api.nvim_get_runtime_file('', true),
    },
    diagnostics = {
      globals = { 'vim' },
    },
  },
}
