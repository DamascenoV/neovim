local status, null_ls = pcall(require, 'null-ls')
if not status then return end

null_ls.setup({
    sources = {
        null_ls.builtins.diagnostics.eslint,
        null_ls.builtins.completion.spell,
        -- php
        null_ls.builtins.diagnostics.phpcs,
        null_ls.builtins.formatting.phpcbf,
        -- go
        null_ls.builtins.diagnostics.golangci_lint,
        null_ls.builtins.formatting.gofmt,
        null_ls.builtins.formatting.goimports
    },
})
