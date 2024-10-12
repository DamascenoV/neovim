return {
  'kristijanhusak/vim-dadbod-ui',
  event = 'BufReadPre',
  cmd = 'DBUI',
  enabled = false,
  dependencies = {
    'tpope/vim-dadbod',
    'kristijanhusak/vim-dadbod-completion'
  }
}
