local vue_language_server_path = os.getenv('HOME') .. '/.nvm/versions/node/v23.11.0/bin/vue-language-server'
local vue_plugin = {
  name = '@vue/typescript-plugin',
  location = vue_language_server_path,
  languages = { 'vue' },
  configNamespace = 'typescript',
}

return {
  cmd = { "vtsls", "--stdio" },
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          vue_plugin,
        },
      },
    },
  },
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
  root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" }
}
