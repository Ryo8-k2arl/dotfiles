-- nvim/after/lsp/texlab.lua

return {
	cmd_env = {
		PATH = vim.env.HOME .. "/.local/bin:" .. vim.env.PATH,
	},
	settings = {
		texlab = {
			build = {
				executable = "latexmk",
				-- The user-wide latexmkrc chooses the engine and output directory.
				args = { "-interaction=nonstopmode", "-synctex=1", "%f" },
				onSave = false,
				forwardSearchAfter = false,
				useFileList = true,
			},
			chktex = {
				onOpenAndSave = true,
				onEdit = false,
			},
			latexFormatter = "latexindent",
			latexindent = {
				modifyLineBreaks = false,
			},
		},
	},
}
