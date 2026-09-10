---@brief
---
--- https://github.com/ubugeeei-prod/vize
---
--- `vize` is an experimental Rust-native Vue toolchain providing SFC compilation,
--- linting, formatting, type-checking, and editor tooling via its LSP.
---
--- Install with: `cargo install vize` or download a prebuilt binary.
---
--- When paired with `tsgols` for TS/JS, vize handles `.vue` files exclusively.
--- `typecheck = true` is safe here because tsgols does not attach to `vue` filetypes,
--- so there is no diagnostic duplication.

---@type vim.lsp.Config
return {
  cmd = { 'vize', 'lsp' },
  filetypes = { 'vue' },
  root_markers = { 'vize.config.pkl', 'vize.config.json', 'package.json', '.git' },
  init_options = {
    editor = true,
    ecosystem = true,
    lint = true,
    typecheck = true,
  },
  settings = {},
}
