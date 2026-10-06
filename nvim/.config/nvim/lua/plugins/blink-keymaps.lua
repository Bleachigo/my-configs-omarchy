return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",

        -- Navigation
        -- Tab: next item when the menu is open, otherwise jump to the next
        -- snippet placeholder / accept the Copilot suggestion
        ["<Tab>"] = {
          "select_next",
          function(cmp)
            return LazyVim.cmp.map({ "snippet_forward", "ai_nes", "ai_accept" })(cmp)
          end,
          "fallback",
        },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
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
