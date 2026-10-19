return {
  "saghen/blink.cmp",
  version = "1.*",
  opts = {
    keymap = {
      preset = "super-tab",
      -- nothing is preselected, so Enter accepts only an item chosen with <C-n> or the arrows
      ["<CR>"] = { "accept", "fallback" },
    },
    completion = {
      list = { selection = { preselect = false } },
      accept = { auto_brackets = { enabled = true } },
      menu = {
        border = "none",
        draw = { treesitter = { "lsp" } },
      },
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
    },
    cmdline = {
      keymap = { preset = "cmdline", ["<Right>"] = false, ["<Left>"] = false },
      completion = {
        list = { selection = { preselect = false } },
        menu = { auto_show = function() return vim.fn.getcmdtype() == ":" end },
        ghost_text = { enabled = true },
      },
    },
  },
}
