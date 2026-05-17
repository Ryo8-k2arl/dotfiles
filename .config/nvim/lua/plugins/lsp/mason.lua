-- nvim/lua/plugins/lsp/mason.lua

return {
  {
    "mason-org/mason.nvim",
    lazy = true,
    build = ":MasonUpdate",
    config = function ()
      require('mason').setup()
    end,
  }
}

