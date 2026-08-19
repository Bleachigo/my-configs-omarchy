return {
  {
    "barrett-ruth/live-server.nvim",
    build = "npm add -g live-server",
    -- This runs BEFORE the plugin loads, satisfying the error requirement
    init = function()
      vim.g.live_server = {
        port = 5500,
        -- If you need more settings, they go here
      }
    end,
    -- We do NOT use 'opts' and we do NOT call .setup()
    -- We just tell Lazy to load the plugin
    config = function()
      -- Just load the commands, don't call .setup()
      require("live-server")
    end,
  },
}
