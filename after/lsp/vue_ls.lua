return {
  cmd = { "vue-language-server", "--stdio" },
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
  init_options = {
    typescript = {
      tsdk = '/Users/victordamasceno/.local/share/nvim/mason/packages/vue-language-server/node_modules/typescript/lib'
    },
    vue = {
      hybridMode = false,
    },
  },
  root_markers = { "package.json" }
}
