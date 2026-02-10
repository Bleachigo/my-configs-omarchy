-- ---------------------------------------
-- Auto-split empty HTML tags on Enter
-- ---------------------------------------
vim.keymap.set("i", "<CR>", function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col(".")
  local before = line:sub(1, col - 1)
  local after = line:sub(col)

  -- Match: <tag>|</tag>
  if before:match("<[%w%-]+>$") and after:match("^</[%w%-]+>") then
    return "<CR><CR><Up>"
  end

  return "<CR>"
end, { buffer = true, expr = true })

-- ---------------------------------------
-- Disable Blink completion when cursor is
-- exactly between opening and closing tags
-- ---------------------------------------
vim.api.nvim_create_autocmd("InsertEnter", {
  buffer = 0,
  callback = function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.fn.col(".")

    local before = line:sub(1, col - 1)
    local after = line:sub(col)

    -- If the cursor is exactly between <tag>|</tag>
    if before:match(">$") and after:match("^</") then
      vim.b.blink_disable = true -- turn completion OFF
    else
      vim.b.blink_disable = false -- turn completion back ON
    end
  end,
})
