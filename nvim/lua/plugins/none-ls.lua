-- Enable none-ls with prettierd for fast Vue/TS formatting

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, config)
    local null_ls = require "null-ls"

    config.sources = {
      null_ls.builtins.formatting.prettierd.with {
        filetypes = {
          "vue",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "json",
          "jsonc",
          "css",
          "scss",
          "html",
          "markdown",
          "yaml",
        },
      },
    }
    return config
  end,
}
