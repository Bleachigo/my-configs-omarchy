-- Oxlint + Oxfmt are the only linter and formatter for JS/TS and web files
-- (ESLint and Prettier extras are turned off in lazyvim.json).
-- Which binary runs:
--   Vite+ project (vite.config.* imports "vite-plus") -> the project's `vp lint` / `vp fmt`,
--     so the `lint` / `fmt` blocks in vite.config.ts apply
--   project with oxlint/oxfmt in node_modules         -> those
--   anything else, including a lone file              -> the Mason copies
-- Files with no oxlint/oxfmt config of their own use the global defaults in
-- ~/.config/nvim/oxc/.oxlintrc.json and .oxfmtrc.json.
-- Oxlint fixes run on save (before oxfmt) and on <leader>cX.

local config_names = { "vite.config.ts", "vite.config.mts", "vite.config.js", "vite.config.mjs" }

-- Folder of the nearest Vite+ config above `path`, or nil
local function vp_root(path)
  local found = vim.fs.find(config_names, { path = path, upward = true, type = "file" })[1]
  if not found then
    return nil
  end
  local f = io.open(found, "r")
  local text = f and f:read("*a") or ""
  if f then
    f:close()
  end
  local root = vim.fs.dirname(found)
  if text:find("vite%-plus") and vim.fn.executable(root .. "/node_modules/.bin/vp") == 1 then
    return root
  end
end

local function buf_vp_root(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  return vp_root(name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd())
end

-- Global defaults for files that have no config of their own
local global_dir = vim.fn.stdpath("config") .. "/oxc"
local global_oxlintrc = global_dir .. "/.oxlintrc.json"
local global_oxfmtrc = global_dir .. "/.oxfmtrc.json"
local oxlint_config_files = { ".oxlintrc.json", ".oxlintrc.jsonc", "oxlint.config.ts" }
local oxfmt_config_files = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }

local function has_config(names, dir)
  return vim.fs.find(names, { path = dir, upward = true, type = "file" })[1] ~= nil
end

-- nvim-lspconfig's own oxlint config (root detection, type-aware setup).
-- Loaded on first use: nvim-lspconfig isn't on the runtimepath while specs load.
local default_oxlint
local function lspconfig_oxlint()
  default_oxlint = default_oxlint or dofile(vim.api.nvim_get_runtime_file("lsp/oxlint.lua", false)[1])
  return default_oxlint
end

-- Folder with an oxlint/Vite+ config above the buffer, or nil
local function oxlint_config_root(bufnr)
  local found
  lspconfig_oxlint().root_dir(bufnr, function(dir)
    found = dir
  end)
  return found
end

-- Apply all safe Oxlint fixes to the buffer and wait for them
local function oxlint_fix(bufnr)
  bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
  local client = vim.lsp.get_clients({ name = "oxlint", bufnr = bufnr })[1]
  if not client then
    return
  end
  client:request_sync("workspace/executeCommand", {
    command = "oxc.fixAll",
    arguments = { { uri = vim.uri_from_bufnr(bufnr) } },
  }, 3000, bufnr)
end

-- Filetypes formatted by oxfmt
local fmt_filetypes = {
  "javascript", "javascriptreact", "typescript", "typescriptreact", "vue",
  "json", "jsonc", "css", "scss", "less", "html", "markdown", "yaml", "graphql", "toml",
}

-- Run after oxfmt for these filetypes (from the markdown extra)
local fmt_extra = {
  markdown = { "markdownlint-cli2", "markdown-toc" },
}

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "oxlint", "oxfmt" })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- oxfmt runs through conform below; its LSP would format a second time
        oxfmt = { enabled = false },
        oxlint = {
          keys = {
            { "<leader>cX", function() oxlint_fix(0) end, desc = "Oxlint: Fix All" },
          },
          -- No oxlint config for this root -> use the global one
          before_init = function(params, config)
            local root = config.root_dir
            if root and not vp_root(root) and not has_config(oxlint_config_files, root) then
              config.settings = config.settings or {}
              config.settings.configPath = global_oxlintrc
            end
            lspconfig_oxlint().before_init(params, config)
          end,
          -- Start everywhere: oxlint config root, else package.json root, else the file's folder
          root_dir = function(bufnr, on_dir)
            local found = oxlint_config_root(bufnr)
            if found then
              return on_dir(found)
            end
            local fname = vim.api.nvim_buf_get_name(bufnr)
            if fname == "" then
              return
            end
            local pkg = vim.fs.find("package.json", { path = vim.fs.dirname(fname), upward = true })[1]
            on_dir(pkg and vim.fs.dirname(pkg) or vim.fs.dirname(fname))
          end,
          cmd = function(dispatchers, config)
            local root = config and config.root_dir
            local vp = root and vp_root(root)
            if vp then
              return vim.lsp.rpc.start({ vp .. "/node_modules/.bin/vp", "lint", "--lsp" }, dispatchers, { cwd = vp })
            end
            local oxlint = root and root .. "/node_modules/.bin/oxlint"
            if oxlint and vim.fn.executable(oxlint) == 1 then
              return vim.lsp.rpc.start({ oxlint, "--lsp" }, dispatchers, { cwd = root })
            end
            return vim.lsp.rpc.start({ "oxlint", "--lsp" }, dispatchers, { cwd = root })
          end,
        },
      },
      setup = {
        oxlint = function()
          -- Fix on save, before the formatter (priority above conform's 100).
          -- Follows the autoformat toggle (<leader>uf / <leader>uF).
          LazyVim.format.register({
            name = "oxlint: fix",
            primary = false,
            priority = 200,
            format = oxlint_fix,
            sources = function(buf)
              return vim.lsp.get_clients({ name = "oxlint", bufnr = buf })[1] and { "oxlint" } or {}
            end,
          })
        end,
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      opts.formatters.vp_fmt = {
        command = function(_, ctx)
          return vp_root(ctx.dirname) .. "/node_modules/.bin/vp"
        end,
        args = { "fmt", "--stdin-filepath", "$FILENAME" },
        stdin = true,
        cwd = function(_, ctx)
          return vp_root(ctx.dirname)
        end,
        require_cwd = true,
      }
      -- conform's built-in "oxfmt" already prefers node_modules/.bin/oxfmt, then PATH (Mason).
      -- No oxfmt config above the file -> use the global one.
      opts.formatters.oxfmt = {
        prepend_args = function(_, ctx)
          if has_config(oxfmt_config_files, ctx.dirname) then
            return {}
          end
          return { "--config", global_oxfmtrc }
        end,
      }

      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(fmt_filetypes) do
        opts.formatters_by_ft[ft] = function(bufnr)
          local list = { buf_vp_root(bufnr) and "vp_fmt" or "oxfmt" }
          return vim.list_extend(list, fmt_extra[ft] or {})
        end
      end
      -- oxfmt doesn't handle MDX; keep only the markdown tools there
      opts.formatters_by_ft["markdown.mdx"] = { "markdownlint-cli2", "markdown-toc" }
    end,
  },
}
