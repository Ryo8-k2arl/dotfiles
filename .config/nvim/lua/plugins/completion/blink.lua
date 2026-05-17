-- nvim/lua/plugins/completion/blink.lua


return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset      = "none",

      -- Enter 補完候補があるときは確定、ないときは通常のEnter
      ["<CR>"]    = { "accept", "fallback" },

      -- Tab / Shift-Tab: 候補移動
      ["<Tab>"]   = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },

      -- Esc: 候補があるときは閉じる。ないときは通常の Normal modea
      ["<Esc>"]   = { "cancel", "fallback" }
    },

    completion = {
      list = {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      },
    },
  },
}
