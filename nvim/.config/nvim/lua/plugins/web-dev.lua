return {

  -- 1) HTML/CSS/JS/TS/JSON/React LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {},
        cssls = {},
        tsserver = {},
        jsonls = {},
      },
    },
  },

  -- 2) Auto-pairs (brackets, quotes)
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  -- 4) Snippets (HTML, CSS, JS, React)
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- 5) Emmet — fast HTML/CSS expansion
  {
    "mattn/emmet-vim",
    ft = { "html", "css", "javascriptreact", "typescriptreact" },
    init = function()
      vim.g.user_emmet_leader_key = "<C-e>" -- CTRL+E shortcuts
    end,
  },
}
