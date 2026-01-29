return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",

        -- Navigation
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },

        -- Accept with Enter (only if popup is visible)
        ["<CR>"] = { "accept", "fallback" },

        -- Close popup with ESC
        -- "hide" works only if popup is visible
        -- "fallback" escapes insert if Popup is NOT visible
        ["<Esc>"] = { "hide", "fallback" },
      },
    },
  },
}
