return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "folke/neodev.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
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

      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline', option = { ignore_cmds = { 'Man', '!' } } }
        })
      })

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
          { name = 'buffer' },
          { name = 'luasnip' },
          { name = 'nvim_lsp_signature_help' },
          { name = "cody" },
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<S-Space>'] = cmp.mapping.complete(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-i>'] = cmp.mapping.scroll_docs(4),
          ['<C-y'] = cmp.mapping.confirm({
            select = true,
          }),
          ['<C-l>'] = cmp.mapping(function ()
            if ls.expand_or_jumpable() then
              ls.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function ()
            if ls.jumpable(-1) then
              ls.jump(-1)
            end
          end, { 'i', 's' }),
        })
      }

      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = {
          "cssls",
          "elixirls",
          "emmet_language_server",
          "golangci_lint_ls",
          "gopls",
          "intelephense",
          "lua_ls",
          "ocamllsp",
          "rust_analyzer",
          "tsserver",
          "v_analyzer",
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

      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })
    end
  }
}
