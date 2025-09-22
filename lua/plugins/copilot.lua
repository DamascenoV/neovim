MiniDeps.later(function()
  MiniDeps.add({
    source = 'zbirenbaum/copilot.lua',
    depends = { 'copilotlsp-nvim/copilot-lsp' },
  })

  require("copilot").setup({
    nes = {
      enabled = true,
      keymap = {
        accept_and_goto = "<leader><tab>",
        accept = false,
        dismiss = "<Esc>",
      },
    },
    suggestion = {
      keymap = {
        accept = '<C-l>'
      }
    }
  })
  vim.g.copilot_nes_debounce = 250
end)
