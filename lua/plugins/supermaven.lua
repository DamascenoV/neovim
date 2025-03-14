return {
  -- 'github/copilot.vim',
  -- lazy = true,
  -- event = 'InsertEnter',
  -- cmd = 'Copilot',
  -- opts = {
    -- suggestion = {
    --   enabled = true,
    --   auto_trigger = true,
    --   hide_during_completion = true,
    --   debounce = 75,
    --   keymap = {
    --     accept = "<C-y>",
    --     accept_word = false,
    --     accept_line = false,
    --     next = false,
    --     prev = false,
    --     dismiss = "<C-u>",
    --   },
    -- },
  -- },
  'supermaven-inc/supermaven-nvim',
  event = 'InsertEnter',
  opts = {
    keymaps = {
      accept_word = "<C-l>",
    }
  }
}
