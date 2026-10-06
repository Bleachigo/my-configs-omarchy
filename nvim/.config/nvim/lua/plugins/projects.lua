-- <leader>fp: find projects (folders with .git, package.json, Makefile, ...) under these dirs
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        projects = {
          dev = { "~/Work", "~/Projects" },
          max_depth = 8, -- e.g. ~/Work/work/Hillel/full-stack/react/redux-45
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
