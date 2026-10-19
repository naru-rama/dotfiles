return {
  "b0o/incline.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-mini/mini.icons" },
  opts = {
    window = { margin = { vertical = 0, horizontal = 1 } },
    -- with one window, lualine and bufferline already show the file name
    hide = { cursorline = "smart", only_win = true },
    render = function(props)
      local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
      local icon, hl = require("mini.icons").get("file", filename)
      if vim.bo[props.buf].modified then
        filename = "[+] " .. filename
      end
      return { { icon, group = hl }, " ", filename }
    end,
  },
}
