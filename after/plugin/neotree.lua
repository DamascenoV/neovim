local status, neotree = pcall(require, 'neo-tree')
if not status then return end

neotree.setup {
  default_component_configs = {
    icon = {
      folder_empty = '-'
    }
  },
  window = {
    position = "right",
  },
  source_selector = {
    winbar = true,
    statusline = false
  },
  buffers = {
    follow_current_file = {
      enabled = true
    }
  },
  filesystem = {
      follow_current_file = {
          enabled = true
      }
  }
}
