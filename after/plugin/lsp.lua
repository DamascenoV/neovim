local status, lsp = pcall(require, 'lsp-zero')
if not status then return end

lsp.preset('recommended')

lsp.on_attach(function(_, bufnr)
  lsp.default_keymaps({
    buffer = bufnr,
    exclude = { 'F2', 'F3', 'F4', 'gl' }
  })
end)

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    'html',
    'cssls',
    'tsserver',
    'intelephense',
    'lua_ls',
    'volar',
    'rust_analyzer',
    'gopls',
    'golangci_lint_ls',
  },
  handlers = {
    lsp.default_setup
  }
})

require('neodev').setup()

local cmp = require('cmp')
local cmp_window = require('cmp.config.window')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup.cmdline('/', {
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

cmp.setup {
  window = {
    completion = cmp_window.bordered(),
    documentation = cmp_window.bordered()
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
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    })
}

lsp.set_preferences {
  sign_icons = {
    error = 'E',
    warn = 'W',
    hint = 'H',
    info = 'I'
  }
}

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
})

local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup {
  settings = {
    Lua = { workspace = { checkThirdParty = false }, semantic = { enable = false }, hint = { enable = false } },
  },
}

lspconfig.gopls.setup {
  settings = {
    gopls = {
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      }
    }
  }
}

lspconfig.tsserver.setup({
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      }
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      }
    }
  }
})

lspconfig.ocamllsp.setup{
  get_language_id = function(_, ftype)
      return ftype
    end,
}

lspconfig.ocamllsp.setup{}

-- For Work with Flex
lspconfig.intelephense.setup({
  filetypes = {
    "php",
    "pfxml",
    "blade",
  }
})

lspconfig.elixirls.setup({})

lsp.setup()
