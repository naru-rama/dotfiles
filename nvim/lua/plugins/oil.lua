return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-mini/mini.icons" },
  cmd = "Oil",
  keys = {
    { "<leader>o", function() require("oil").open_float(nil, { preview = {} }) end, desc = "Open oil" },
  },
  opts = {
    -- nvim-tree opens directories
    default_file_explorer = false,
    columns = {
      "icon",
      { "permissions", highlight = "Type" },
      { "size", highlight = "String" },
      { "mtime", highlight = "Keyword" },
    },
    keymaps = {
      ["h"] = { "actions.parent", mode = "n" },
      ["q"] = { "actions.close", mode = "n" },
    },
    view_options = { show_hidden = true },
    float = {
      padding = 8,
      border = "rounded",
      win_options = { winblend = 0 },
      max_width = 200,
    },
    preview_win = { update_on_cursor_moved = true },
    lsp_file_methods = { enabled = true, timeout_ms = 1000, autosave_changes = true },
  },
}
