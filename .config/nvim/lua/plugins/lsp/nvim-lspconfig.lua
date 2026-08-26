-- nvim/lua/plugins/lsp/nvim-lspconfig.lua

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ty = {},
        ruff = {},
      },
    },
  },
}
