---@type LazySpec
return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
      fuzzy = {
        prebuilt_binaries = {
          force_version = "1.3.1",
        },
        sorts = {
          "exact",
          "score",
          function(a, b)
            local a_under = a.label:sub(1, 1) == "_"
            local b_under = b.label:sub(1, 1) == "_"
            if a_under ~= b_under then return b_under end
          end,
          "sort_text",
          "label",
        },
      },
      sources = {
        default = { "lsp", "snippets", "path", "buffer" },
        providers = {
          lsp = { score_offset = 10 },
          snippets = { score_offset = 5 },
          path = { score_offset = 3 },
          buffer = { score_offset = -3 },
        },
      },
      completion = {
        menu = {
          draw = {
            components = {
              label = { width = { max = 40 }, ellipsis = true },
            },
          },
        },
      },
    },
  },
  {
    "moyiz/blink-emoji.nvim",
    specs = {
      {
        "saghen/blink.cmp",
        opts = {
          sources = {
            default = { "emoji" },
            providers = {
              emoji = { name = "Emoji", module = "blink-emoji", score_offset = -1 },
            },
          },
        },
      },
    },
  },
}
