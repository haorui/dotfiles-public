---@type LazySpec
return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "BufEnter",
    config = function()
      require("supermaven-nvim").setup {}
    end,
  },
}
