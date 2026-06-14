-- nvim/lua/plugins/lsp/mason.lua

return {
  {
    "mason-org/mason.nvim",
    lazy = true,
    build = ":MasonUpdate",
    config = function ()
      require('mason').setup()
    end,
    opts = {},
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependecies = { "mason-org/mason.nvim" },
    cmd = {
      "MasonToolsInstall",
      "MasonToolsInstallSync",
      "MasonToolsUpdate",
      "MasonToolsUpdateSync",
    },
    opts = {
      ensure_installed = {
        -- Lua
        -- Rust
        "rust-analyzer",

        -- Python
        "ruff",
        "ty",

        -- LaTeX
        "texlab",
        "latexindent",
        -- Markdown
        -- Shell
        --
      },
      auto_update = false,
      run_on_start = true,
    },
  },
}
