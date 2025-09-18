return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    -- add more things to the ensure_installed table protecting against community packs modifying it
    opts.filesystem = {
      filtered_items = {
        visible = true,
      },
    }
  end,
}
