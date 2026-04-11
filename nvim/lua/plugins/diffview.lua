---@type LazySpec
return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = { layout = "diff3_mixed" },
      },
    },
  },
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<Leader>gd"] = { "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
          ["<Leader>gD"] = { "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diffview vs main" },
          ["<Leader>gf"] = { "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
          ["<Leader>gF"] = { "<cmd>DiffviewFileHistory<cr>", desc = "Project history" },
          ["<Leader>gq"] = { "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
        },
      },
    },
  },
}
