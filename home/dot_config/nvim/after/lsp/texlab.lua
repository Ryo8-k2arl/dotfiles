-- nvim/after/lsp/texlab.lua

return {
	cmd_env = {
		PATH = vim.env.HOME .. "/.local/bin:" .. vim.env.PATH,
	},
	settings = {
		texlab = {
			build = {
				executable = "latexmk",
				args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
				onSave = false,
				forwardSearchAfter = false,
			},
			chktex = {
				onOpenAndSave = false,
				onEdit = false,
			},
			latexFormatter = "latexindent",
			latexindent = {
				modifyLineBreaks = false,
			},
		},
	},
}
