return {
  "nvim-mini/mini.icons",
  lazy = true,
  opts = {},
  init = function()
    -- plugins that use nvim-web-devicons get mini.icons' icons instead
    package.preload["nvim-web-devicons"] = function()
      require("mini.icons").mock_nvim_web_devicons()
      return package.loaded["nvim-web-devicons"]
    end
  end,
}
