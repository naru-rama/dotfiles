local parsers = {
  "bash",
  "diff",
  "go",
  "gomod",
  "gosum",
  "gowork",
  "hcl",
  "helm",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "nix",
  "query",
  "regex",
  "terraform",
  "toml",
  "vim",
  "vimdoc",
  "yaml",
}

return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install(parsers)
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
