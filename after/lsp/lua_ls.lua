return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.stdpath('config') .. '/lua'] = true,
        },
        maxPreload = 10000,
        preloadFileSize = 10000,
      },
    },
  },
}
