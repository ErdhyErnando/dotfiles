-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- install language servers (names from :Mason)
        "lua-language-server",
        "vtsls", -- vtsls (TS/JS + vue typescript plugin)
        "html-lsp", -- html
        "tailwindcss-language-server", -- tailwindcss
        "vue-language-server", -- vue_ls
        "pyright", -- pyright
        "clangd", -- clangd
        "emmet-ls", -- emmet_ls

        -- install formatters
        "stylua",

        -- install debuggers
        "debugpy",

        -- install any other package
        "tree-sitter-cli",
      },
    },
  },
}
