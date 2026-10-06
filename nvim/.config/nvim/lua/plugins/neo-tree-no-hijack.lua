-- Don't let neo-tree take over `nvim <dir>`; config/no_dir_buffers.lua handles that
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = { hijack_netrw_behavior = "disabled" },
  },
}
