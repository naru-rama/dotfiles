return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
  opts = {
    -- snacks.nvim draws the diagram below the closing fence, which this plugin would conceal
    code = { disable = { "mermaid" } },
  },
}
