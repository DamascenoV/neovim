local status, neotree = pcall(require, 'neo-tree')
if not status then return end

neotree.setup {
  default_component_configs = {
    icon = {
      folder_empty = '-'
    }
  }
}
