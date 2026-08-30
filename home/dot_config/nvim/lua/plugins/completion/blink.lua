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
			["<CR>"] = {
				"accept",
				function()
					return require("config.latex").item_newline()
				end,
				"fallback",
			},
			-- Alt-Enter always inserts a regular newline inside list environments.
			["<M-CR>"] = { "fallback" },

			-- Tab / Shift-Tab: snippet placeholderを優先し、それ以外では候補移動
			["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
			["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },

			-- Esc: 候補があるときは閉じる。ないときは通常の Normal modea
			["<Esc>"] = { "cancel", "fallback" },
		},

		snippets = {
			preset = "luasnip",
		},

		completion = {
			trigger = {
				-- Rust keywords such as `pub`, `fn`, and `struct` should open the menu while typing.
				show_on_keyword = true,
				show_on_trigger_character = true,
			},
			menu = {
				auto_show = true,
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 300,
			},
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
}
