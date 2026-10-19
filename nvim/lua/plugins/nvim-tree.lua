return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-mini/mini.icons" },
  cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
  },
  init = function()
    -- nvim-tree replaces netrw
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function(data)
        if vim.fn.isdirectory(data.file) ~= 1 then
          return
        end
        vim.cmd.cd(data.file)
        require("nvim-tree.api").tree.open()
      end,
    })
  end,
  opts = {
    filters = { dotfiles = false },
  },
  config = function(_, opts)
    require("nvim-tree").setup(opts)

    -- otherwise :q in the last window leaves only the tree open
    vim.api.nvim_create_autocmd("QuitPre", {
      callback = function()
        local api = require("nvim-tree.api")
        local wins = vim.tbl_filter(function(win)
          return vim.api.nvim_win_get_config(win).relative == ""
            and not api.tree.is_tree_buf(vim.api.nvim_win_get_buf(win))
        end, vim.api.nvim_tabpage_list_wins(0))
        if #wins == 1 then
          api.tree.close()
        end
      end,
    })
  end,
}
