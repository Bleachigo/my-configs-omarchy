local M = {}

function M.extract_classes()
  -- get selected text or whole buffer
  local mode = vim.fn.mode()
  local text = ""

  if mode == "v" or mode == "V" then
    local _, ls, cs = unpack(vim.fn.getpos("'<"))
    local _, le, ce = unpack(vim.fn.getpos("'>"))
    text = table.concat(vim.fn.getline(ls, le), "\n")
    text = string.sub(text, cs, #text - (#text - ce))
  else
    text = table.concat(vim.fn.getline(1, "$"), "\n")
  end

  -- ordered list of classes
  local ordered = {}
  local seen = {}

  -- find class="..."
  for classlist in text:gmatch('class="(.-)"') do
    for class in classlist:gmatch("%S+") do
      if not seen[class] then
        table.insert(ordered, class)
        seen[class] = true
      end
    end
  end

  -- also support className="..." (React JSX)
  for classlist in text:gmatch('className="(.-)"') do
    for class in classlist:gmatch("%S+") do
      if not seen[class] then
        table.insert(ordered, class)
        seen[class] = true
      end
    end
  end

  if #ordered == 0 then
    print("No classes found.")
    return
  end

  -- build CSS blocks
  local result = {}
  for _, class in ipairs(ordered) do
    table.insert(result, "." .. class .. " {\n    \n}")
  end

  local output = table.concat(result, "\n\n")
  vim.fn.setreg("+", output)

  print("Copied " .. tostring(#ordered) .. " CSS classes to clipboard (preserved order).")
end

return M
