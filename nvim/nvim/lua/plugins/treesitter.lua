return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			local config = require("nvim-treesitter.configs")
			config.setup({
				ensure_installed = {
					"html",
					"javascript",
					"typescript",
					"css",
					"tsx",
					"css",
					"json",
					"lua",
				},
				auto_install = true,
				highlight = { enable = true },
				indent = { enable = true },

				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							["a="] = "@assignment.outer",
							["i="] = "@assignment.inner",
							["aB"] = "@block.outer",
							["iB"] = "@block.inner",

							["at"] = "@tag.outer",
							["it"] = "@tag.inner",
							["a'"] = "@string.outer",
							["i'"] = "@string.inner",
							['a"'] = "@string.outer",
							['i"'] = "@string.inner",
							["a`"] = "@string.outer",
							["i`"] = "@string.inner",
							["ap"] = "@parameter.outer",
							["ip"] = "@parameter.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							["]m"] = "@function.outer",
							["]]"] = "@class.outer",
						},
						goto_next_end = {
							["]M"] = "@function.outer",
							["]["] = "@class.outer",
						},
						goto_previous_start = {
							["[m"] = "@function.outer",
							["[["] = "@class.outer",
						},
						goto_previous_end = {
							["[M"] = "@function.outer",
							["[]"] = "@class.outer",
						},
					},
					swap = {
						enable = true,
						swap_next = {
							["<leader>sn"] = "@parameter.inner",
						},
						swap_previous = {
							["<leader>sp"] = "@parameter.inner",
						},
					},
				},
			})
			vim.cmd([[highlight MatchParen ctermbg=darkcyan guibg=#29323c]])
		end,
	},
	{
		"andymass/vim-matchup",
		event = "BufReadPost",
		config = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
			vim.g.matchup_delim_nodes = 1000
			vim.g.matchup_tags_nodes = 5000
		end,
	},
	{
		"folke/which-key.nvim",
		opts = {},
		config = function()
			vim.cmd([[highlight MatchParen ctermbg=darkcyan guibg=#29323c]])
		end,
	},
}
