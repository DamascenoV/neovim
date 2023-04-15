local status, dap_virtual_text = pcall(require, 'nvim-dap-virtual-text')
if not status then return end
dap_virtual_text.setup {
  enabled = true,
  enabled_commands = false,
  highlight_changed_variables = true,
  highlight_new_as_changed = true,
  commented = false,
  show_stop_reason = true,
  virt_text_pos = "eol", -- position of virtual text, see `:h nvim_buf_set_extmark()`
  all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
}
