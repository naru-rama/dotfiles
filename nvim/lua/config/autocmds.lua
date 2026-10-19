-- 'autoread' only reloads files changed outside Neovim (e.g. by Claude Code in another pane) when Neovim checks
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd.checktime()
    end
  end,
})
