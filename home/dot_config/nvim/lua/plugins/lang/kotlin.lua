-- nvim/lua/plugins/lang/kotlin.lua
--
-- Kotlin and Android support. Formatting is delegated to the Kotlin Language
-- Server, which carries IntelliJ's own formatter, so no separate ktlint or
-- ktfmt binary is installed. Server behaviour lives in
-- nvim/after/lsp/kotlin_lsp.lua.

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				vim.list_extend(opts.ensure_installed, { "kotlin" })
			end
		end,
	},

	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				kotlin = { "lsp" },
			},
		},
	},

	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				-- Installed by Mason like every other language server here; see
				-- nvim/lua/plugins/lsp/mason.lua. Server behaviour lives in
				-- nvim/after/lsp/kotlin_lsp.lua.
				kotlin_lsp = {},
			},
		},
	},
}
