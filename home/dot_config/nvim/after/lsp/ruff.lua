-- nvim/after/lsp/ruff.lua

return {
  cmd = { "ruff", "server" },
  filetypes = { "python" },

  init_options = {
    settings = {
    logLevel = "warn",
    },
  },
}
