-- nvim/after/lsp/kotlin_lsp.lua
--
-- JetBrains Kotlin Language Server, installed by Mason (package kotlin-lsp).
-- The archive bundles its own JetBrains Runtime, so no JDK lookup is needed,
-- and bin/intellij-server speaks LSP over stdio without socat or netcat.
-- nvim-lspconfig already supplies the command and the Gradle/Maven root
-- markers, so only the behaviour that differs is set here.
--
-- Android caveat: the server resolves the generated R class only after a build
-- has produced it, so run `./gradlew processDebugResources` (or assembleDebug)
-- once in a fresh checkout before expecting R.string.* to resolve.

-- The server applies generic Kotlin naming rules and does not know that
-- @Composable functions are PascalCase by convention, so it reports every
-- composable as "should start with a lowercase letter". Drop that one
-- diagnostic in buffers that actually use Compose, and leave it in place
-- everywhere else so genuine naming problems still surface.
local naming_message = "should start with a lowercase letter"

local function uses_compose(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end
	for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 120, false)) do
		if line:find("androidx.compose", 1, true) then
			return true
		end
	end
	return false
end

local function filter_composable_naming(err, result, ctx, config)
	if result and result.diagnostics and #result.diagnostics > 0 then
		local bufnr = vim.uri_to_bufnr(result.uri)
		if uses_compose(bufnr) then
			result.diagnostics = vim.tbl_filter(function(diagnostic)
				local message = diagnostic.message or ""
				if not message:find(naming_message, 1, true) then
					return true
				end
				-- Keep it unless the offending name is PascalCase.
				return message:match("'%u[%w_]*'") == nil
			end, result.diagnostics)
		end
	end
	return vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, config)
end

return {
	-- Kotlin resolution depends on the whole Gradle model; a detached buffer
	-- would start a server that cannot resolve anything.
	single_file_support = false,
	handlers = {
		["textDocument/publishDiagnostics"] = filter_composable_naming,
	},
}
