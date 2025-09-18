local is_available = require("astrocore").is_available
local utils = require "astrocore"
local M = {}

function M.mappings(maps) maps.n["<Leader>n"] = false end
--
return M
