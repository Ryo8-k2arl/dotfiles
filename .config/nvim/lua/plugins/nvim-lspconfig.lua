-- -*- encoding: utf-8 -*-

return {
  'neovim/nvim-lspconfig',
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    vim.lsp.enable({
      "rust_analyzer",
    })
  end,
}

