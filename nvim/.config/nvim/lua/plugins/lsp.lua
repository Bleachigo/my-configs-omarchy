return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cssls = {},
        html = {
          -- without a css.lint table html-lsp crashes validating <style> blocks ("validProperties" of null)
          settings = { css = { lint = {} } },
        },
        jsonls = {},
        lua_ls = {},
        -- start tailwind only in projects that use it (the default also falls back to any .git folder)
        tailwindcss = {
          root_dir = function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            local markers = require("lspconfig.util").insert_package_json({
              "tailwind.config.js",
              "tailwind.config.cjs",
              "tailwind.config.mjs",
              "tailwind.config.ts",
            }, "tailwindcss", fname)
            local found = vim.fs.find(markers, { path = fname, upward = true })[1]
            if found then
              on_dir(vim.fs.dirname(found))
            end
          end,
        },
        -- Додаємо налаштування саме для emmet_ls
        emmet_ls = {
          -- only markup/style files (no plain JS/TS), so it doesn't run on every keystroke there
          filetypes = { "html", "css", "scss", "javascriptreact", "typescriptreact" },
          init_options = {
            preferences = {
              ["maxRepeat"] = 50,
            },
          },
        },
      },
      setup = {
        ["*"] = function(server, opts)
          -- залишайте ваш існуючий код setup без змін
          local disabled_formatting = { "cssls", "html", "jsonls", "lua_ls" }
          for _, name in ipairs(disabled_formatting) do
            if server == name then
              opts.on_attach = function(client, bufnr)
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
              end
            end
          end
        end,
      },
    },
  },
}
