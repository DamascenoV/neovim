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
        split = {
          width = 69,
          height = 20,
        },
      },
      tools = {
        copilot = { cmd = { "copilot" }, url = "https://github.com/github/copilot-cli" },
      },
    },
  })
end)
