-- Follow the GNOME dark/light toggle (freedesktop color-scheme portal).
-- ghostty switches itself via `theme = light:...,dark:...` and darkman switches
-- tmux; this file makes Neovim keep up with astrodark/astrolight.

local dark_mode = {}

-- Query the freedesktop appearance portal.
-- Values: 0 = no preference (renders light), 1 = prefer-dark, 2 = prefer-light.
function dark_mode.appearance()
  if vim.uv.os_uname().sysname ~= "Linux" then return "dark" end
  local ok, result = pcall(function()
    return vim
      .system({
        "gdbus",
        "call",
        "--session",
        "--dest",
        "org.freedesktop.portal.Desktop",
        "--object-path",
        "/org/freedesktop/portal/desktop",
        "--method",
        "org.freedesktop.portal.Settings.ReadOne",
        "org.freedesktop.appearance",
        "color-scheme",
      }, { timeout = 2000, text = true })
      :wait()
  end)
  if not ok or result.code ~= 0 or not result.stdout then return "dark" end
  if result.stdout:find "uint32 1" then return "dark" end
  return "light"
end

---@type LazySpec
return {
  -- Runtime switching: poll the portal while Neovim is open and flip the
  -- colorscheme the moment the GNOME toggle changes (up to 3s delay).
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false, -- must run from startup to track the system theme
    ---@module "auto-dark-mode"
    ---@type AutoDarkModeOptions
    opts = {
      fallback = dark_mode.appearance() == "dark" and "dark" or "light",
      update_interval = 3000,
      set_dark_mode = function()
        vim.o.background = "dark"
        if vim.g.colors_name ~= "astrodark" then vim.cmd.colorscheme "astrodark" end
      end,
      set_light_mode = function()
        vim.o.background = "light"
        if vim.g.colors_name ~= "astrolight" then vim.cmd.colorscheme "astrolight" end
      end,
    },
  },
  -- Startup selection: pick the colorscheme before astrodark's default kicks in.
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = function(_, opts)
      opts.colorscheme = dark_mode.appearance() == "dark" and "astrodark" or "astrolight"
      return opts
    end,
  },
}
