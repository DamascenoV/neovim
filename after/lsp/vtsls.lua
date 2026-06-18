local function first_existing_dir(paths)
  for _, path in ipairs(paths) do
    if path ~= '' and vim.fn.isdirectory(path) == 1 then return path end
  end
end

local function vue_language_server_location()
  local candidates = {}
  local function add(path)
    if path and path ~= '' then table.insert(candidates, path) end
  end

  local exe = vim.fn.exepath('vue-language-server')
  if exe ~= '' then add(vim.fs.dirname(vim.fs.dirname(exe)) .. '/lib/node_modules/@vue/language-server') end

  local home = vim.env.HOME
  if home then
    for _, path in
      ipairs(
        vim.fn.glob(
          home .. '/.local/share/mise/installs/npm-vue-language-server/*/lib/node_modules/@vue/language-server',
          true,
          true
        )
      )
    do
      add(path)
    end
    for _, path in
      ipairs(
        vim.fn.glob(home .. '/.local/share/mise/installs/node/*/lib/node_modules/@vue/language-server', true, true)
      )
    do
      add(path)
    end
  end

  return first_existing_dir(candidates) or candidates[1]
end

local vue_plugin = {
  name = '@vue/typescript-plugin',
  location = vue_language_server_location(),
  languages = { 'vue' },
  configNamespace = 'typescript',
}

return {
  cmd = { 'vtsls', '--stdio' },
  init_options = {
    hostInfo = 'neovim',
  },
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
  root_markers = { 'tsconfig.json', 'package.json', 'jsconfig.json', '.git' },
}
