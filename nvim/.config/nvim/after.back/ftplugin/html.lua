-- Auto-split <tag>|</tag> with perfect indent & cursor alignment
vim.keymap.set("i", "<CR>", function()
  local row = vim.fn.line(".")
  local col = vim.fn.col(".")
  local line = vim.api.nvim_get_current_line()

  local before = line:sub(1, col - 1)
  local after = line:sub(col)

  -- Detect empty HTML element <tag>|</tag>
  local open_tag = before:match("<([%w%-]+)>$")
  local close_tag = after:match("^</([%w%-]+)>")

  if open_tag and close_tag and open_tag == close_tag then
    -- Step 1: Insert 2 new lines, move cursor to middle
    local keys = vim.api.nvim_replace_termcodes("<CR><CR><Up>", true, false, true)

    -- We return intermediate keys so Neovim creates the lines
    -- Then we adjust indentation AFTER the split using vim.schedule()
    vim.schedule(function()
      local r = vim.fn.line(".")
      local indent = vim.fn.indent(r)

      -- Move cursor to correct indent column
      vim.fn.cursor(r, indent + 1)
    end)

    return keys
  end

  return "<CR>"
end, { buffer = true, expr = true })
