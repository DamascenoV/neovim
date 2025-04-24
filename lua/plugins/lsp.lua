return {
  'neovim/nvim-lspconfig',
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
  },
  config = function()
    local lspconfig = require('lspconfig')
    require('mason').setup({
      ui = {
        border = 'rounded',
        height = 0.5,
      },
    })
    require('mason-lspconfig').setup({
      ensure_installed = {
        'cssls',
        'emmet_language_server',
        'intelephense',
        'lua_ls',
        'rust_analyzer',
        'elixirls',
        -- "vtsls",
        'volar',
      },
      handlers = {
        function(server_name) lspconfig[server_name].setup({}) end,
      },
    })

    lspconfig.lua_ls.setup({
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
      }
    })

    lspconfig.gleam.setup({
      cmd = { 'gleam', 'lsp' },
    })

    lspconfig.ocamllsp.setup({})

    lspconfig.elixirls.setup({
      settings = {
        elixirLS = {
          dialyzerEnabled = true,
          suggestSpecs = true,
        },
      },
    })

    lspconfig.volar.setup({
      filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
      init_options = {
        vue = {
          hybridMode = false,
        },
      },
    })
  end,
}
