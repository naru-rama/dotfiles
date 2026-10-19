return {
  "craftzdog/solarized-osaka.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("solarized-osaka").setup({
      style = "vivid",
      -- brighter than the default 0.3 for more contrast; Ghostty's foreground matches the resulting Normal fg
      vivid_brightness = 0.5,
      -- show Ghostty's translucent background
      transparent = true,
      on_highlights = function(hl)
        -- the default is light text on a light background, which is hard to read in the completion menu
        hl.PmenuSel = { bg = "#13505f", bold = true }
        -- the default is a vivid red background
        hl.MatchParen = { bg = "#13505f", bold = true }
        -- incline.nvim (file name at the top right of split windows) is vivid pink by default
        hl.InclineNormal = { bg = "#13505f", fg = hl.Normal.fg }
        -- keys (blue) and string values (cyan) look almost the same, so keys use the body text color
        for _, group in ipairs({
          "@property.yaml",
          "@variable.member.terraform",
          "@variable.member.hcl",
          "@lsp.type.property.terraform",
          "@lsp.type.parameter.terraform",
        }) do
          hl[group] = { link = "Normal" }
        end
      end,
    })
    vim.cmd.colorscheme("solarized-osaka")
  end,
}
