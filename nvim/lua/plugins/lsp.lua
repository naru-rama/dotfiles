local function organize_imports(buf)
  local client = vim.lsp.get_clients({ bufnr = buf, name = "gopls" })[1]
  if not client then
    return
  end
  local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
  params.context = { only = { "source.organizeImports" }, diagnostics = {} }
  local res = client:request_sync("textDocument/codeAction", params, 1000, buf)
  for _, action in ipairs(res and res.result or {}) do
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    end
  end
end

-- yamlls picks per-kind and CRD schemas only for files mapped to "kubernetes" in its settings,
-- so map each manifest found by content rather than by folder
local function use_k8s_schema(buf)
  local client = vim.lsp.get_clients({ bufnr = buf, name = "yamlls" })[1]
  if not client then
    return
  end
  local schemas = client.settings.yaml.schemas
  schemas.kubernetes = schemas.kubernetes or {}
  -- yamlls matches patterns against the encoded file URI
  local path = vim.uri_from_bufnr(buf):gsub("^file://", "")
  -- kustomization.yaml has apiVersion and kind but its own schema from SchemaStore
  if vim.list_contains(schemas.kubernetes, path) or vim.fs.basename(path):match("^kustomization%.ya?ml$") then
    return
  end
  local keys = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    keys[line:match("^(%w+):") or ""] = true
  end
  if not (keys.apiVersion and keys.kind) then
    return
  end
  table.insert(schemas.kubernetes, path)
  client:notify("workspace/didChangeConfiguration", { settings = client.settings })
end

return {
  "neovim/nvim-lspconfig",
  dependencies = { "b0o/SchemaStore.nvim" },
  config = function()
    vim.lsp.config("gopls", {
      settings = {
        gopls = {
          gofumpt = true,
          staticcheck = true,
        },
      },
    })
    vim.lsp.config("yamlls", {
      settings = {
        yaml = {
          -- SchemaStore.nvim provides the catalog instead
          schemaStore = { enable = false, url = "" },
          schemas = require("schemastore").yaml.schemas(),
          -- formatting would rewrite whole manifests on every save
          format = { enable = false },
        },
      },
    })
    vim.lsp.enable({ "gopls", "terraformls", "yamlls", "helm_ls" })

    local icons = require("config.icons").diagnostics
    vim.diagnostic.config({
      severity_sort = true,
      virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = icons.error,
          [vim.diagnostic.severity.WARN] = icons.warn,
          [vim.diagnostic.severity.INFO] = icons.info,
          [vim.diagnostic.severity.HINT] = icons.hint,
        },
      },
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf, desc = "Go to definition" })
      end,
    })

    vim.api.nvim_create_autocmd({ "LspAttach", "TextChanged", "TextChangedI" }, {
      callback = function(args) use_k8s_schema(args.buf) end,
    })

    -- conform formats on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      callback = function(args) organize_imports(args.buf) end,
    })
  end,
}
