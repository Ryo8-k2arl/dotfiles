-- -*- encoding: utf-8 -*-
-- .config/nvim/lua/plugins/colorscheme.lua

return {
  { "xiyaowong/transparent.nvim" },                 -- 透過用
  { "catppuccin/nvim", "neanias/everforest-nvim" }, -- Color Scheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-macchiato"
    }
  }
}

