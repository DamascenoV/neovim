return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local lspconfig = require("lspconfig")
      require('mason').setup({
        ui = {
          border = 'rounded'
        }
      })
      require('mason-lspconfig').setup({
        ensure_installed = {
          "cssls",
          "emmet_language_server",
          "intelephense",
          "lua_ls",
          "rust_analyzer",
          "elixirls",
          -- "ts_ls",
          "volar",
        },
        handlers = {
          function(server_name)
            lspconfig[server_name].setup({
            })
          end
        }
      })

      lspconfig.gleam.setup({
        cmd = { "gleam", "lsp" },
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
        init_options = {
          vue = {
            hybridMode = false,
          },
          typescript = {
            tsdk = '/home/damascenov/.local/share/nvim/mason/bin/typescript-language-server/node_modules/typescript/lib'
          }
        },
      })
    end
  }
}
