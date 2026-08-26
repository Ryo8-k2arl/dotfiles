-- nvim/lua/plugins/lang/rust.lua

return {
	{
		"mrcjkb/rustaceanvim",
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
