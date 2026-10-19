vim.filetype.add({
  -- an empty .tf file is otherwise detected as TinyFugue
  extension = { tf = "terraform" },
  pattern = {
    -- only inside a Helm chart, so other templates/ folders stay yaml
    [".*/templates/.*%.ya?ml"] = function(path)
      if vim.fs.root(path, "Chart.yaml") then
        return "helm"
      end
    end,
    [".*/templates/.*%.tpl"] = "helm",
  },
})
