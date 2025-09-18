return {
  "aserowy/tmux.nvim",
  config = function()
    require("tmux").setup {
      copy_sync = {
        -- 无需配置，默认开启
      },
      navigation = {
        -- 开启在 nvim 和 tmux 窗格间无缝跳转
        enable_default_keybindings = true,
      },
      resize = {
        -- 开启使用快捷键调整 nvim 和 tmux 窗格大小
        enable_default_keybindings = false,
      },
    }
  end,
}
