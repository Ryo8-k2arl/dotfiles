-- nvim/lua/plugins/lang/rust.lua

return {
	{
		"mrcjkb/rustaceanvim",
		-- rustaceanvim implements its own lazy-loading through the Rust
		-- filetype plugin; keep lazy.nvim from delaying that integration.
		version = "^9",
		lazy = false,
		-- Load blink.cmp before rustaceanvim starts rust-analyzer.
		dependencies = { "saghen/blink.cmp" },
		opts = {
			server = {
				default_settings = {
					["rust-analyzer"] = {
						cargo = {
							features = "all",
							noDeps = false,
							sysroot = "discover",
						},
						check = {
							command = "clippy",
						},
						completion = {
							autoimport = {
								enable = true,
							},
						},
					},
				},
			},
		},
	},
}
