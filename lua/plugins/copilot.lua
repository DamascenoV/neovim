return {
  "copilotlsp-nvim/copilot-lsp",
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  init = function()
    vim.g.copilot_nes_debounce = 250
    vim.lsp.enable("copilot")
  end,
}
