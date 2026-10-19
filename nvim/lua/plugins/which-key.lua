return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>g", group = "git" },
      { "<leader>h", group = "hunks (gitsigns)" },
      { "<leader>t", group = "toggle" },
    },
  },
  keys = {
    { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer keymaps" },
  },
}
