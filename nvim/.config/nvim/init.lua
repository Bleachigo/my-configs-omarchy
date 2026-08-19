-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
local parser_path = "/home/artiplex/.local/share/nvim/site/"
vim.opt.runtimepath:prepend(parser_path)
