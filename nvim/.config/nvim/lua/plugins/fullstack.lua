-- Extra pieces for full-stack JS on top of the LazyVim extras in lazyvim.json
return {
  -- Run Jest / Vitest tests from the editor (<leader>t...)
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
    },
    opts = {
      adapters = {
        ["neotest-jest"] = {
          -- needed by projects that use ES modules (import/export) with Jest
          env = { NODE_OPTIONS = "--experimental-vm-modules" },
          -- the adapter's own config lookup uses vim.fn.glob, which crashes inside neotest
          jestConfigFile = function(file)
            local names = { "jest.config.ts", "jest.config.js", "jest.config.mjs", "jest.config.cjs" }
            return vim.fs.find(names, { path = vim.fs.dirname(file), upward = true, type = "file" })[1]
          end,
        },
        ["neotest-vitest"] = {},
      },
    },
  },

  -- Syntax highlighting for files the extras don't cover
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "graphql", "jsdoc", "regex", "scss", "http" },
    },
  },
}
