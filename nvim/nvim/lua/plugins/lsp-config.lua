return {
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
        opts = {
            auto_install = true,
        },
    },
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            vim.lsp.config("ts_ls", {
                capabilities = capabilities,
            })
            vim.lsp.config("html", {
                capabilities = capabilities,
            })
            vim.lsp.config("lua_ls", {
                capabilities = capabilities,
            })
            vim.lsp.config("tailwindcss", {
                capabilities = capabilities,
            })
            vim.lsp.config("hls", {
                capabilities = capabilities,
            })
            vim.lsp.config("pyright", {
                capabilities = capabilities,
            })
            vim.lsp.config("clangd", {
                capabilities = capabilities,
            })
            vim.lsp.config("emmet_ls", {
                capabilities = capabilities,
            })

            vim.lsp.enable("ts_ls")
            vim.lsp.enable("html")
            vim.lsp.enable("lua_ls")
            vim.lsp.enable("tailwindcss")
            vim.lsp.enable("hls")
            vim.lsp.enable("pyright")
            vim.lsp.enable("clangd")
            vim.lsp.enable("emmet_ls")

            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })

            vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
            vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

            vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
            vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
            vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
        end,
    },
}
