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

return M
