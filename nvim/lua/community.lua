-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.recipes.heirline-nvchad-statusline" },
  -- override nvchad mode component: colored text, transparent bg
  {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
      if not opts.statusline then return end
      local status = require "astroui.status"
      local mode_map = {
        n = "normal_fg", no = "normal_fg", nov = "normal_fg", noV = "normal_fg",
        niI = "normal_fg", niR = "normal_fg", niV = "normal_fg",
        i = "insert_fg", ic = "insert_fg", ix = "insert_fg",
        v = "visual_fg", V = "visual_fg", ["\22"] = "visual_fg",
        s = "visual_fg", S = "visual_fg", ["\19"] = "visual_fg",
        R = "replace_fg", Rc = "replace_fg", Rx = "replace_fg", Rv = "replace_fg",
        c = "command_fg", cv = "command_fg",
        t = "terminal_fg",
      }
      -- replace index 2 (mode component set by nvchad recipe)
      opts.statusline[2] = status.component.mode {
        mode_text = {
          icon = { kind = "VimIcon", padding = { right = 1, left = 1 } },
        },
        hl = function()
          return { fg = mode_map[vim.fn.mode()] or "normal_fg", bold = true }
        end,
        surround = {
          separator = "left",
          color = function() return { main = "NONE", right = "blank_bg" } end,
          update = { "ModeChanged", pattern = "*:*" },
        },
      }
    end,
  },
  -- import/override with your plugins folder
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.tailwindcss" },
  { import = "astrocommunity.pack.vue" },
  { import = "astrocommunity.pack.svelte" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.java" },
}
