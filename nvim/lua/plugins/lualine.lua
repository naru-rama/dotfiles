local icons = require("config.icons")

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-mini/mini.icons" },
  opts = {
    options = { globalstatus = true },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch" },
      lualine_c = {
        { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
        { "filename", path = 1, symbols = { modified = " ●", readonly = " \u{f033e}" } },
      },
      lualine_x = {
        -- cmdheight = 0 hides the "recording @q" message
        {
          function() return "recording @" .. vim.fn.reg_recording() end,
          cond = function() return vim.fn.reg_recording() ~= "" end,
        },
        { "diagnostics", symbols = icons.diagnostics },
        {
          "diff",
          symbols = icons.git,
          source = function()
            local status = vim.b.gitsigns_status_dict
            if status then
              return { added = status.added, modified = status.changed, removed = status.removed }
            end
          end,
        },
      },
      lualine_y = { { "progress", separator = " ", padding = { left = 1, right = 1 } } },
      lualine_z = { { "location", padding = { left = 1, right = 1 } } },
    },
  },
}
