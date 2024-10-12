return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "folke/neodev.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "saadparwaiz1/cmp_luasnip",
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp"
      },
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require('neodev').setup()
      require("luasnip.loaders.from_vscode").lazy_load()

      local cmp = require('cmp')
      local cmp_lsp = require('cmp_nvim_lsp')
      local cmp_window = require('cmp.config.window')
      local lspconfig = require("lspconfig")

      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_lsp.default_capabilities())

      local ls = require('luasnip')

      cmp.setup {
        snippet = {
          expand = function(args)
            ls.lsp_expand(args.body)
          end
        },
        window = {
          completion = cmp_window.bordered(),
          documentation = cmp_window.bordered()
        },
        completion = {
          completeopt = 'menu,menuone,noinsert,noselect'
        },
        sources = {
          { name = 'path' },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'cody' },
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<S-Space>'] = cmp.mapping.complete(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-i>'] = cmp.mapping.scroll_docs(4),
          ['<C-y'] = cmp.mapping.confirm({
            select = true,
          }),
          ['<C-l>'] = cmp.mapping(function()
            if ls.expand_or_jumpable() then
              ls.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if ls.jumpable(-1) then
              ls.jump(-1)
            end
          end, { 'i', 's' }),
        })
      }

      require('mason').setup({
        ui = {
          border = 'rounded'
        }
      })
      require('mason-lspconfig').setup({
        ensure_installed = {
          "cssls",
          "emmet_language_server",
          "golangci_lint_ls",
          "gopls",
          "intelephense",
          "lua_ls",
          "rust_analyzer",
          -- "ts_ls",
          "volar",
        },
        handlers = {
          function(server_name)
            lspconfig[server_name].setup({
              capabilities = capabilities,
            })
          end
        }
      })

      lspconfig.gleam.setup({
        cmd = { "gleam", "lsp" },
        capabilities = capabilities,
      })

      lspconfig.lexical.setup({
        cmd = { "/home/damascenov/.local/share/nvim/mason/bin/lexical" },
        capabilities = capabilities,
      })

      lspconfig.ocamllsp.setup({
        capabilities = capabilities,
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
        capabilities = capabilities
      })
    end
  }
}
