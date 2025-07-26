MiniDeps.add('copilotlsp-nvim/copilot-lsp')

MiniDeps.later(function()
  vim.g.copilot_nes_debounce = 250
end)
