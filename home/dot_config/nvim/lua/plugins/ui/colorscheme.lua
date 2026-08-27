-- nvim/lua/plugins/colorscheme.lua

return {
  { "xiyaowong/transparent.nvim" },                            -- 透過用
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 }, -- Color Scheme
  { "neanias/everforest-nvim", priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-macchiato"
    }
  }
}

