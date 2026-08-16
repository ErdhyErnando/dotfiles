---@type LazySpec
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
  ft = { "markdown" },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    -- Enable for markdown files by default
    enabled = true,
    -- Render modes: normal, insert, visual, command, operator
    render_modes = { "n", "c" },
    -- Maximum file size to render (in lines)
    max_file_size = 10.0,
    -- Anti-conceal settings (hides virtual text on cursor line)
    anti_conceal = {
      enabled = true,
      -- Number of lines above/below cursor to show rendered text
      above = 0,
      below = 0,
    },
    -- Heading configuration
    heading = {
      enabled = true,
      icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      signs = { "󰫎 " },
      position = "overlay",
      width = "block",
      min_width = 80,
      border = false,
      border_virtual = false,
    },
    -- Code block configuration
    code = {
      enabled = true,
      style = "full",
      position = "left",
      language_pad = 0,
      disable_background = { "diff" },
      width = "block",
      min_width = 80,
      left_margin = 0,
      left_pad = 0,
      right_pad = 0,
      border = "thin",
      above = "▄",
      below = "▀",
      inline = true,
    },
    -- Bullet list configuration
    bullet = {
      enabled = true,
      icons = { "●", "○", "◆", "◇" },
      ordered_icons = {},
      left_pad = 0,
      right_pad = 0,
      highlight = "RenderMarkdownBullet",
    },
    -- Checkbox configuration
    checkbox = {
      enabled = true,
      position = "inline",
      unchecked = {
        icon = "󰄱 ",
        highlight = "RenderMarkdownUnchecked",
      },
      checked = {
        icon = "󰱒 ",
        highlight = "RenderMarkdownChecked",
      },
    },
    -- Quote configuration
    quote = {
      enabled = true,
      icon = "▋",
      repeat_linebreak = false,
    },
    -- Table configuration
    table = {
      enabled = true,
      style = "full",
      cell = "padded",
      border = true,
      alignment_indicator = "━",
    },
    -- Dash configuration
    dash = {
      enabled = true,
      icon = "─",
      width = "block",
      highlight = "RenderMarkdownDash",
    },
    -- Link configuration
    link = {
      enabled = true,
      image = "󰥶 ",
      email = "󰀓 ",
      hyperlink = "󰌹 ",
      custom = {},
    },
    -- Latex configuration
    latex = {
      enabled = true,
      converter = "latex2text",
      highlight = "RenderMarkdownLatex",
      position = "above",
      top_pad = 0,
      bottom_pad = 0,
    },
    -- Callout configuration (GitHub & Obsidian style)
    callout = {
      note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
      tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
      important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
      warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
      caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
    },
  },
}
