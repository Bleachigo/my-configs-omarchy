-- No LaTeX math in my markdown: turn it off (no latex parser/tools needed)
return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    latex = { enabled = false },
  },
}
