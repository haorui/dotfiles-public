-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme astrodark"
    -- colorscheme = "astrodark",
    colorscheme = "catppuccin-mocha",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = function()
        local get_hlgroup = require("astroui").get_hlgroup
        return {
          CursorLineFold = { link = "CursorLineNr" },
          GitSignsCurrentLineBlame = { fg = get_hlgroup("NonText").fg, italic = true },
          HighlightURL = { underline = true },
          OctoEditable = { fg = "NONE", bg = "NONE" },
          -- transparent tabline
          TabLine = { bg = "NONE" },
          TabLineFill = { bg = "NONE" },
          TabLineSel = { bg = "NONE" },
        }
      end,
    },
    -- Transparent statusline (override heirline-nvchad colors)
    status = {
      separators = {
        left = { "", " " },
        right = { " ", "" },
        tab = { "", "" },
      },
      colors = function(hl)
        local get_hlgroup = require("astroui").get_hlgroup
        -- transparent statusline segment backgrounds
        hl.blank_bg = "NONE"
        hl.file_info_bg = "NONE"
        hl.nav_icon_bg = "NONE"
        hl.folder_icon_bg = "NONE"
        hl.nav_fg = get_hlgroup("String").fg
        -- transparent tabline
        hl.tabline_bg = "NONE"
        hl.buffer_bg = "NONE"
        hl.buffer_active_bg = "NONE"
        hl.buffer_visible_bg = "NONE"
        -- save original mode colors for fg, then set bg to NONE
        hl.normal_fg = hl.normal
        hl.insert_fg = hl.insert
        hl.visual_fg = hl.visual
        hl.replace_fg = hl.replace
        hl.command_fg = hl.command
        hl.terminal_fg = hl.terminal
        hl.inactive_fg = hl.inactive
        hl.normal = "NONE"
        hl.insert = "NONE"
        hl.visual = "NONE"
        hl.replace = "NONE"
        hl.command = "NONE"
        hl.terminal = "NONE"
        hl.inactive = "NONE"
        return hl
      end,
    },
    -- Icons can be configured throughout the interface
    icons = {
      -- configure the loading of the lsp in the status line
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
