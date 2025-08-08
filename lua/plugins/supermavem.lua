MiniDeps.later(function()
  MiniDeps.add({
    source = 'supermaven-inc/supermaven-nvim',
  })

  require('supermaven-nvim').setup({
    keymaps = {
      accept_suggestion = '<C-l>'
    }
  })
end)
