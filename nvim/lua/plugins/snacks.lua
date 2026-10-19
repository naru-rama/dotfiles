return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    indent = { enabled = true, animate = { enabled = false } },
    image = {
      enabled = true,
      -- the default 80x40 shrinks tall Mermaid diagrams until the text is unreadable
      doc = { max_width = 120, max_height = 80 },
      convert = {
        -- render at 2x and let the terminal scale it down, which keeps the text sharp
        mermaid = function()
          local theme = vim.o.background == "light" and "neutral" or "dark"
          return { "-i", "{src}", "-o", "{file}", "-b", "transparent", "-t", theme, "-s", "2" }
        end,
      },
    },
    lazygit = {
      theme = { activeBorderColor = { fg = "WarningMsg", bold = true } },
    },
    notifier = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    picker = {
      sources = {
        files = { hidden = true },
        grep = { hidden = true },
      },
    },
  },
  keys = {
    { "<leader><space>", function() Snacks.picker.files() end, desc = "Find files" },
    { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "LazyGit" },
    { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub pull requests" },
  },
}
