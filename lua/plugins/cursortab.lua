MiniDeps.later(function()
  MiniDeps.add({
    source = "leonardcser/cursortab.nvim",
  })

  require("cursortab").setup({
    enabled = true,
    provider = {
      type = "sweep",
      url = "http://localhost:11434",
      model = "hf.co/sweepai/sweep-next-edit-1.5B",
      api_key_env = "",
    },
  })
end)
