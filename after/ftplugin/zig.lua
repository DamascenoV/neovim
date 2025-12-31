-- Zig error format
vim.opt_local.errorformat = {
    "%f:%l:%c: %m",
    "%f:%l: %m",
    "%.%#panicked at '%.%#', %f:%l:%c",
}
