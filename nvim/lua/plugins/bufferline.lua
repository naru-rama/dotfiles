return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-mini/mini.icons" },
  keys = {
    { "<Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
    -- keeps the window layout, unlike :bdelete
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete buffer" },
  },
  opts = {
    options = {
      diagnostics = "nvim_lsp",
      always_show_bufferline = false,
      offsets = { { filetype = "NvimTree", separator = true } },
    },
  },
}
