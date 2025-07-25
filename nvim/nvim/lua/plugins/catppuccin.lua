return {
	{
		"catppuccin/nvim",
		lazy = false,
		name = "catppuccin",
		priority = 1000,
		config = function()
			-- require("catppuccin").setup({
			-- 	transparent_background = true,
			-- 	integrations = {
			-- 		telescope = true,
			-- 		neo_tree = true,
			-- 		gitsigns = true,
			-- 		treesitter = true,
			-- 	},
			-- })
			-- vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},
}
