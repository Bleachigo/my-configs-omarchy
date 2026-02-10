return {
  {
    "local/class-extractor",
    dir = vim.fn.stdpath("config") .. "/lua/local/class-extractor",
    keys = {
      {
        "<leader>xc",
        function()
          require("local.class-extractor").extract_classes()
        end,
        desc = "Extract CSS classes (like eCSStractor)",
        mode = { "n", "v" },
      },
    },
  },
}
