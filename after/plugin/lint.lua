local status, lint = pcall(require, 'lint')
if not status then return end

lint.linters_by_ft = {
  php = { 'phpcs', 'php'}
}

vim.cmd [[au BufWritePost * lua require'lint'.try_lint()]]
