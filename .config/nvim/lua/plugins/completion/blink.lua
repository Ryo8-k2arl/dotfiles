-- nvim/lua/plugins/completion/blink.lua

return {
	"saghen/blink.cmp",

	-- 260614 ver. 1
	version = "1.*",

	---@module "blink.cmp"
	---@type blink.cmp.Config
	opts = {
		keymap = {
			preset = "enter",

			-- Enter 補完候補があるときは確定、ないときは通常のEnter
			["<CR>"] = { "accept", "fallback" },

			-- Tab / Shift-Tab: 候補移動
			["<Tab>"] = { "select_next", "fallback" },
			["<S-Tab>"] = { "select_prev", "fallback" },

			-- Esc: 候補があるときは閉じる。ないときは通常の Normal modea
			["<Esc>"] = { "cancel", "fallback" },
		},

		snippets = {
			preset = "luasnip",
		},

		sources = {
			default = {
				"lsp",
				"path",
				"snippets",
				"buffer",
			},
		},

		completion = {
			list = {
				selection = {
					-- 自動で最初の候補を選ばない
					preselect = false,
					-- 候補移動だけで本文に仮挿入しない
					auto_insert = false,
				},
			},
		},

		fuzzy = {
			implementation = "prefer_rust_with_warning",
		},
	},

	opt_extend = {
		"sources.default",
	},
}
