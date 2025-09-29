MiniDeps.later(function()
  MiniDeps.add({
    source = 'folke/sidekick.nvim',
  })

  require("sidekick").setup({
    nes = {
      debounce = 100
    },
    cli = {
      watch = true,
      win = {
        width = 50,
        height = 20,
      },
    },
  })
end)
