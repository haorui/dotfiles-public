-- Replace none-ls with conform.nvim for formatting

---@type LazySpec
return {
  -- disable none-ls
  { "nvimtools/none-ls.nvim", enabled = false },

  -- use conform.nvim for formatting
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    opts = {
      formatters_by_ft = {
        vue = { "prettierd" },
        javascript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        css = { "prettierd" },
        scss = { "prettierd" },
        html = { "prettierd" },
        markdown = { "prettierd" },
        yaml = { "prettierd" },
      },
      format_on_save = {
        timeout_ms = 4000,
        lsp_fallback = true,
      },
    },
  },
}
