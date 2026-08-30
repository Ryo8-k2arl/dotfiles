-- nvim/lua/plugins/lang/latex.lua

return {
	{
		"lervag/vimtex",
		lazy = false,
		init = function()
			-- VimTeX owns LaTeX highlighting and editing features. TexLab owns
			-- builds, while PDF preview remains disabled until a terminal viewer
			-- is configured.
			vim.g.vimtex_syntax_enabled = 1
			vim.g.vimtex_compiler_enabled = 0
			vim.g.vimtex_view_enabled = 0
			vim.g.vimtex_quickfix_mode = 0
			vim.g.vimtex_mappings_disable = { n = { "K" } }
		end,
	},

	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				texlab = {
					keys = {
						{ "<localleader>lb", "<cmd>LspTexlabBuild<cr>", desc = "LaTeX: build once" },
					},
				},
			},
		},
	},
}
