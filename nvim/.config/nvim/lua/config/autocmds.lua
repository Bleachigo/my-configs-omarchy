-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local buffers = vim.api.nvim_list_bufs()
    for _, bufnr in ipairs(buffers) do
      if vim.api.nvim_buf_get_name(bufnr) == "" and vim.bo[bufnr].buftype == "" and not vim.bo[bufnr].modified then
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end
    end
  end,
})
