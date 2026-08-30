-- nvim/lua/plugins/snippets/luasnip.lua

return {
	"L3MON4D3/LuaSnip",

	event = "InsertEnter",
	dependencies = { "rafamadriz/friendly-snippets" },

	config = function()
		local ls = require("luasnip")

		ls.config.setup({
			enable_autosnippets = false,
			region_check_events = "InsertEnter",
			delete_check_events = "TextChanged,InsertLeave",
		})

		-- Load the LaTeX Workshop-compatible snippets bundled with
		-- friendly-snippets (BEQ, BIT, BEN, @-prefixed math symbols, etc.).
		require("luasnip.loaders.from_vscode").load({
			include = { "tex", "plaintex", "bib" },
		})

		-- user snippets
		local ok_tex, tex_snippets = pcall(require, "snippets.tex")
		if ok_tex then
			ls.add_snippets("tex", tex_snippets)
		end
	end,
}
