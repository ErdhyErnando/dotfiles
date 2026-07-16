---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = function(_, opts)
    -- enable the same language servers as the previous custom config
    if not opts.servers then opts.servers = {} end
    vim.list_extend(opts.servers, {
      "ts_ls",
      "html",
      "lua_ls",
      "tailwindcss",
      "hls",
      "pyright",
      "clangd",
      "emmet_ls",
    })
  end,
}
