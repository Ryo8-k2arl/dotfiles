-- nvim/lua/plugins/lsp/mason.lua

return {
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				-- Rust
				"rust-analyzer",

				-- Python
				"ruff",
				"ty",

				-- LaTeX
				"texlab",

				-- Web / Markdown
				"prettierd",
			},
		},
	},
}
