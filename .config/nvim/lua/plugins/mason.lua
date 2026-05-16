-- -*- encoding: utf-8 -*-
-- .config/nvim/lua/plugins/mason.lua

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

