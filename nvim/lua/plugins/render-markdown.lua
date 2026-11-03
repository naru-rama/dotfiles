return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
  opts = {
    -- snacks.nvim draws the diagram below the closing fence, which this plugin would conceal
    code = { disable = { "mermaid" } },
    -- keep the cursor line rendered too; only insert mode shows the raw text
    anti_conceal = { enabled = false },
    win_options = { concealcursor = { rendered = "nc" } },
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)

    -- table rows wrapped across lines always turn raw under the cursor, with no option to change it:
    -- hide() checks mark.replace for that, so take it away during the call
    local updater = require("render-markdown.core.ui").updater
    local hide = updater.hide
    updater.hide = function(self, extmark, range)
      local mark = extmark:get()
      local replace = mark.replace
      mark.replace = nil
      local hidden = hide(self, extmark, range)
      mark.replace = replace
      return hidden
    end
  end,
}
