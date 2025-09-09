MiniDeps.later(function()
  MiniDeps.add({
    source = 'zbirenbaum/copilot.lua',
  })

  require("copilot").setup({
    suggestion = {
      keymap = {
        accept = '<C-l>'
      }
    }
  })
end)
