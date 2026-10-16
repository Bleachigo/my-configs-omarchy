-- <leader>fp and the dashboard "Projects" button: find projects (folders with .git,
-- package.json, Makefile, ...) under these dirs

-- Open a project cleanly: save the current project's session and close its files
-- before changing folder. Otherwise the old files stay open, and on quit they get
-- saved into the new project's session (that's how one project ended up
-- reopening another project's files).
local function switch_project(picker, item)
  picker:close()
  if not item then
    return
  end

  local file_bufs = vim.tbl_filter(function(b)
    return vim.bo[b].buflisted and vim.bo[b].buftype == "" and vim.api.nvim_buf_get_name(b) ~= ""
  end, vim.api.nvim_list_bufs())

  for _, b in ipairs(file_bufs) do
    if vim.bo[b].modified then
      Snacks.notify.warn("Save or discard your changes before switching projects")
      return
    end
  end

  if #file_bufs > 0 then
    local ok, persistence = pcall(require, "persistence")
    if ok and persistence.active() then
      vim.api.nvim_exec_autocmds("User", { pattern = "PersistenceSavePre" })
      persistence.save()
    end
    Snacks.bufdelete.all({ wipe = true })
  end

  -- the default action: cd, restore the session or open the file finder
  require("snacks.picker.actions").load_session(picker, item)
end

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        projects = {
          dev = { "~/Work", "~/Projects" },
          max_depth = 8, -- e.g. ~/Work/work/Hillel/full-stack/react/redux-45
          confirm = switch_project,
          -- ~/Work/work is a symlink to /data/work: use the real path so the same
          -- project isn't listed twice and its saved session (keyed by path) is found
          transform = function(item, ctx)
            item.file = vim.uv.fs_realpath(item.file) or item.file
            item.text = item.file
            ctx.meta.seen = ctx.meta.seen or {}
            if ctx.meta.seen[item.file] then
              return false
            end
            ctx.meta.seen[item.file] = true
          end,
        },
      },
    },
  },
}
