-- rustaceanvim starts a client named "rust-analyzer" (with a hyphen).
-- Keep this in after/lsp so it wins over any earlier LSP config.

---@type vim.lsp.Config
local capabilities = vim.deepcopy(vim.lsp.config["*"].capabilities or {})

-- Preserve rustaceanvim's Rust-specific capabilities and add blink.cmp's
-- completion capabilities.  The file is evaluated once while the static LSP
-- configuration is resolved, before the client is started.
capabilities = vim.tbl_deep_extend(
	"force",
	capabilities,
	require("rustaceanvim.config.server").create_client_capabilities(),
	require("blink.cmp").get_lsp_capabilities({}, false)
)

return {
	capabilities = capabilities,
}
