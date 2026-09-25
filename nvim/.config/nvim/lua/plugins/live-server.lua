return {
  {
    -- Moved from GitHub to Forgejo (GitHub repo removed Oct 31, 2026). See :help live-server-migration
    url = "https://forge.barrettruth.com/barrettruth/live-server.nvim",
    name = "live-server.nvim",
    -- Must be set before the plugin loads; no setup() call is needed
    init = function()
      vim.g.live_server = {
        port = 5500,
        -- If you need more settings, they go here
      }
    end,
  },
}
