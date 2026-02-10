-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Налаштування клавіш для extract-css.lua
vim.keymap.set({ "n", "v" }, "<leader>xc", function()
  require("extract_css").extract_classes()
end, { desc = "Extract CSS classes (eCSStractor)" })
