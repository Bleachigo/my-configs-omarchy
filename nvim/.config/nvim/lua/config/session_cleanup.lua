-- Delete saved sessions whose project folder no longer exists (renamed or deleted).
-- * runs automatically shortly after startup
-- * :SessionsClean runs it by hand and says what was removed
--
-- Safety: a session is removed only if the first two levels of its path still
-- exist (e.g. /data/work). So if the /data drive isn't mounted, nothing is deleted.

local M = {}

local function session_dir()
  local ok, config = pcall(require, "persistence.config")
  if ok and config.options and config.options.dir then
    return config.options.dir
  end
  return vim.fn.stdpath("state") .. "/sessions/"
end

-- the project folder is the `cd` line that :mksession writes near the top
local function project_dir(file)
  local f = io.open(file, "r")
  if not f then
    return nil
  end
  local dir
  for _ = 1, 30 do
    local line = f:read("*l")
    if not line then
      break
    end
    local d = line:match("^cd (.+)$")
    if d then
      dir = vim.fn.expand(d:gsub("\\(.)", "%1"))
      break
    end
  end
  f:close()
  return dir
end

local function base_exists(dir)
  local base = dir:match("^(/[^/]+/[^/]+)") or dir:match("^(/[^/]+)")
  return base ~= nil and vim.fn.isdirectory(base) == 1
end

---@param verbose? boolean
function M.clean(verbose)
  local removed = {}
  for _, file in ipairs(vim.fn.glob(session_dir() .. "*.vim", true, true)) do
    local dir = project_dir(file)
    if dir and vim.fn.isdirectory(dir) == 0 and base_exists(dir) then
      if os.remove(file) then
        table.insert(removed, dir)
      end
    end
  end
  if #removed > 0 then
    Snacks.notify.info("Removed sessions for missing folders:\n" .. table.concat(removed, "\n"))
  elseif verbose then
    Snacks.notify.info("No sessions for missing folders")
  end
end

function M.setup()
  vim.api.nvim_create_user_command("SessionsClean", function()
    M.clean(true)
  end, { desc = "Delete sessions whose project folder no longer exists" })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("session_cleanup", { clear = true }),
    callback = function()
      vim.defer_fn(M.clean, 2000)
    end,
  })
end

return M
