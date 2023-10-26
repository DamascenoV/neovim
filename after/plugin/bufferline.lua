local status, bufferline = pcall(require, 'bufferline')
if not status then return end

bufferline.setup {
  options = {
    offsets = {
      { filetype = "NvimTree", text = "", padding = 1 },
      { filetype = "neo-tree", text = "Explorer", padding = 1 },
      { filetype = "Outline", text = "", padding = 1 },
    },
    max_name_length = 14,
    max_prefix_length = 13,
    tab_size = 10,
    separator_style = "thin",
  },
}
