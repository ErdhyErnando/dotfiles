---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = function(_, opts)
    -- enable the same language servers as the previous custom config
    if not opts.servers then opts.servers = {} end
    vim.list_extend(opts.servers, {
      "vtsls", -- TS/JS + TypeScript inside .vue (needs @vue/typescript-plugin below)
      "html",
      "lua_ls",
      "tailwindcss",
      "vue_ls", -- vue-language-server: required for Vue/Nuxt projects
      "pyright",
      "clangd",
      "emmet_ls",
      -- NOTE: "ts_ls" was replaced by "vtsls" (vtsls supports the
      -- @vue/typescript-plugin, ts_ls does not in this lspconfig version).
      -- Running both at once is not recommended: nvim would start two TS
      -- servers on the same buffer. "tsgo" does NOT work with Vue either:
      -- vue_ls only forwards TypeScript requests to ts_ls/vtsls/
      -- typescript-tools clients, and tsgo cannot load the vue plugin.
      -- NOTE: "hls" was removed because Mason cannot install
      -- haskell-language-server on this machine: its installer requires
      -- `ghcup`, which is not installed (install failed with exit 127 every
      -- time, see ~/.local/state/nvim/mason.log). To use Haskell LSP, first
      -- install ghcup (https://www.haskell.org/ghcup/) and then re-add
      -- "hls" here and "haskell-language-server" in plugins/mason.lua.
    })

    -- emmet_ls can fail its first attach with "emmet-ls is not executable":
    -- the initial LSP attach races with Mason prepending its bin dir to
    -- PATH (see ~/.local/state/nvim/lsp.log). Point the cmd at the absolute
    -- Mason binary path so the executable check always succeeds.
    local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"
    if not opts.config then opts.config = {} end
    opts.config.emmet_ls = {
      cmd = { mason_bin .. "/emmet-ls", "--stdio" },
    }

    -- Vue 3 "hybrid mode": vue_ls only manages HTML/CSS sections of .vue
    -- files; TypeScript inside .vue is handled by a TS server hosting the
    -- @vue/typescript-plugin. vtsls is the documented setup:
    -- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/vtsls.lua
    local vue_language_server_path = vim.fn.stdpath "data"
      .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
    local vue_plugin = {
      name = "@vue/typescript-plugin",
      location = vue_language_server_path,
      languages = { "vue" },
      configNamespace = "typescript",
    }
    opts.config.vtsls = {
      -- absolute path, same startup-race fix as emmet_ls
      cmd = { mason_bin .. "/vtsls", "--stdio" },
      settings = {
        vtsls = {
          tsserver = {
            globalPlugins = { vue_plugin },
          },
        },
      },
      -- attach to .vue buffers as well so vue_ls can forward TS requests
      filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
    }
  end,
}
