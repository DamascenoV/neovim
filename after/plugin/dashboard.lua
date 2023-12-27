local status, alpha = pcall(require, "alpha")
if not status then return end

local statusdash, dashboard = pcall(require, "alpha.themes.dashboard")
if not statusdash then return end

dashboard.section.header.val = {""}
dashboard.section.buttons.val = {
    dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
    dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
    dashboard.button("m", "  Mason", ":Mason <CR>"),
    dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
}

alpha.setup(dashboard.opts)

vim.api.nvim_create_autocmd("User", {
    callback = function()
        local stats = require("lazy").stats()
        local ms = math.floor(stats.startuptime * 100) / 100
        dashboard.section.footer.val = "󱐌 Lazy-loaded "
            .. stats.loaded
            .. "/"
            .. stats.count
            .. " plugins in "
            .. ms
            .. "ms"
        pcall(vim.cmd.AlphaRedraw)
    end,
})

