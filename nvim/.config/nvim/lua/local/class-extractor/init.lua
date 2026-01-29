local M = {}

function M.extract_classes()
  local mode = vim.fn.mode()
  local text = ""

  ------------------------------------------------------------------------------
  -- VISUAL MODE
  ------------------------------------------------------------------------------
  if mode == "v" or mode == "V" then
    local ls, cs = unpack(vim.api.nvim_buf_get_mark(0, "<"))
    local le, ce = unpack(vim.api.nvim_buf_get_mark(0, ">"))
    local lines = vim.api.nvim_buf_get_lines(0, ls - 1, le, false)

    -- fix first and last lines
    lines[1] = string.sub(lines[1], cs)
    lines[#lines] = string.sub(lines[#lines], 1, ce)

    text = table.concat(lines, "\n")

  ------------------------------------------------------------------------------
  -- NORMAL MODE — whole buffer
  ------------------------------------------------------------------------------
  else
    text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  end

  ------------------------------------------------------------------------------
  -- Extract classes
  ------------------------------------------------------------------------------
  local classes = {}

  for classlist in text:gmatch("class%s*=%s*[\"'](.-)[\"']") do
    for class in classlist:gmatch("%S+") do
      classes[class] = true
    end
  end

  if next(classes) == nil then
    print("No classes found.")
    return
  end

  ------------------------------------------------------------------------------
  -- Build CSS
  ------------------------------------------------------------------------------
  local result = {}
  for class in pairs(classes) do
    table.insert(result, "." .. class .. " {\n    \n}")
  end

  ------------------------------------------------------------------------------
  -- Copy to clipboard
  ------------------------------------------------------------------------------
  vim.fn.setreg("+", table.concat(result, "\n\n"))

  print("Copied CSS for " .. tostring(#result) .. " classes to clipboard!")
end

return M
