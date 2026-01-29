return {
  {
    "nvim-mini/mini.surround",
    opts = function(_, opts)
      opts.mappings = opts.mappings or {}

      -- Replace add mapping (default is 'sa')
      opts.mappings.add = "gs"

      -- Custom wrapper for tags
      opts.custom_surroundings = opts.custom_surroundings or {}
      opts.custom_surroundings.t = {
        output = function()
          local tag = vim.fn.input("Tag: ")
          if tag == "" then
            return nil
          end
          return {
            left = "<" .. tag .. ">",
            right = "</" .. tag .. ">",
          }
        end,
      }

      return opts
    end,
  },
}
