local M = {}

local function termcodes(keys)
	return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

---Reproduce LaTeX Workshop's Enter behavior for list items.
---@return string|nil keys Keys to execute, or nil for the normal Enter behavior.
function M.item_newline()
	if not vim.tbl_contains({ "tex", "plaintex" }, vim.bo.filetype) then
		return nil
	end

	local line = vim.api.nvim_get_current_line()
	local column = vim.api.nvim_win_get_cursor(0)[2]
	local before_cursor = line:sub(1, column)
	local content = before_cursor:match("^%s*(.*)$")
	local prefix, text = content:match("^(\\item%s*%b[])(.*)$")

	if not prefix then
		prefix, text = content:match("^(\\item)(%s.*)$")
	end
	if not prefix and content == "\\item" then
		prefix, text = "\\item", ""
	end
	if not prefix then
		return nil
	end

	-- Enter on an otherwise empty item removes it, which exits the list flow.
	local full_content = line:match("^%s*(.-)%s*$")
	if column == #line and (full_content == prefix or full_content:match("^\\item%s*%b[]$") or full_content == "\\item") then
		return termcodes("<C-o>0<C-o>D")
	end

	if text:match("%S") or column < #line then
		return termcodes("<CR>" .. prefix .. " ")
	end

	return nil
end

---Complete LaTeX environments after a leading backslash, as in LaTeX Workshop.
---@param findstart integer
---@param base string
---@return integer|table
function M.environment_omnifunc(findstart, base)
	if not vim.tbl_contains({ "tex", "plaintex" }, vim.bo.filetype) then
		return findstart == 1 and -3 or {}
	end

	if findstart == 1 then
		local line = vim.api.nvim_get_current_line()
		local column = vim.api.nvim_win_get_cursor(0)[2]
		local before_cursor = line:sub(1, column)
		local start = before_cursor:match(".*()\\[%w@*]*$")
		return start or -3
	end

	local ok, items = pcall(vim.fn["vimtex#complete#complete"], "env", base, "")
	items = ok and items or {}

	-- VimTeX discovers most package environments from its completion files or
	-- standard \newenvironment declarations. tabularray creates its core
	-- environments through \NewTblrEnviron instead, so include them explicitly
	-- when that package is active.
	if vim.b.vimtex and vim.b.vimtex.packages and vim.b.vimtex.packages.tabularray then
		local seen = {}
		for _, item in ipairs(items) do
			seen[type(item) == "table" and item.word or item] = true
		end
		for _, name in ipairs({ "tblr", "longtblr", "talltblr" }) do
			if not seen[name] then
				table.insert(items, { word = name, kind = "[env: tabularray]" })
			end
		end
	end

	return items
end

---Turn VimTeX environment candidates into begin/end snippets.
---@param items table[]
---@return table[]
function M.environment_items(items)
	for _, item in ipairs(items) do
		local name = item.textEdit and item.textEdit.newText or item.insertText or item.label
		if name and name ~= "" then
			item.kind = vim.lsp.protocol.CompletionItemKind.Snippet
			item.insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet
			item.textEdit.newText = ("begin{%s}\n\t$0\n\\end{%s}"):format(name, name)
		end
	end

	return items
end

return M
