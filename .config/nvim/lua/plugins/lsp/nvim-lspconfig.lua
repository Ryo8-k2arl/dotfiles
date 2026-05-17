-- nvim/lua/plugins/lsp/nvim-lspconfig.lua

return {
  'neovim/nvim-lspconfig',
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    vim.lsp.enable({
      "rust_analyzer",
      "ty",
      "ruff",
    })
  end,
}

