-- Never keep a buffer for a directory (the "project-name" buffer with the file tree).
-- * `nvim <dir>`  -> cd into it and show the dashboard instead
-- * sessions      -> don't save directory buffers / the arglist, and drop them
--                    from old sessions when they're restored (<leader>fp)

local M = {}

local function is_dir_buf(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  return name ~= "" and vim.fn.isdirectory(name) == 1
end

local function wipe_dir_bufs()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and is_dir_buf(buf) then
      Snacks.bufdelete({ buf = buf, wipe = true })
    end
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("no_dir_buffers", { clear = true })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    callback = function()
      local arg = vim.fn.argv(0)
      if vim.fn.argc() ~= 1 or vim.fn.isdirectory(arg) == 0 then
        return
      end
      vim.cmd.cd(vim.fn.fnameescape(arg))
      vim.cmd("silent! %argdelete")
      wipe_dir_bufs()
      Snacks.dashboard()
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "PersistenceSavePre",
    callback = function()
      vim.cmd("silent! %argdelete")
      wipe_dir_bufs()
    end,
  })

  vim.api.nvim_create_autocmd("SessionLoadPost", {
    group = group,
    callback = function()
      vim.cmd("silent! %argdelete")
      wipe_dir_bufs()
    end,
  })
end

return M
