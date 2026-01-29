return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- This section allows you to override settings for specific servers
      servers = {
        cssls = {},
        html = {},
        jsonls = {},
        lua_ls = {},
      },
      -- This function runs whenever a server attaches to a buffer
      setup = {
        -- The '*' means apply this logic to ALL servers
        ["*"] = function(server, opts)
          -- Disable formatting for the servers you listed
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
