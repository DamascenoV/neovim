local status, notify = pcall(require, 'notify')
if not status then return end

notify.setup({
  background_colour = "#000000",
  timeout = 2500,
  stages = "static",
  top_down = false,
})


vim.notify = notify
