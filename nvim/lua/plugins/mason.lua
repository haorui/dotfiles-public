---@type LazySpec
return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        "basedpyright",
        "cssls",
        "emmet_ls",
        "eslint",
        "html",
        "jdtls",
        "jsonls",
        "lemminx",
        "lua_ls",
        "svelte",
        "tailwindcss",
        "vtsls",
        "vue_ls",
      })
    end,
  },
  { "jay-babu/mason-null-ls.nvim", enabled = false },
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        "python",
        "javadbg",
        "javatest",
        "js",
      })
    end,
  },
}
