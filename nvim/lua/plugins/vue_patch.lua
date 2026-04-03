-- Patch AstroCommunity Vue pack for Neovim 0.10: replace deprecated `client:exec_cmd`
-- with `client.request("workspace/executeCommand", ...)` when forwarding Volar
-- requests to vtsls. Keeps change in user config (not plugin dir) to survive updates.

---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@param opts AstroLSPOpts
    opts = function(_, opts)
      local astrocore = require "astrocore"

      local function has_function_value(value, depth)
        depth = depth or 0
        if depth > 12 then return false end -- avoid deep recursion
        local t = type(value)
        if t == "function" then return true end
        if t == "table" then
          for k, v in pairs(value) do
            if type(k) == "function" or type(v) == "function" then return true end
            if has_function_value(v, depth + 1) then return true end
          end
        end
        return false
      end

      local function is_json_serializable(obj)
        local ok = pcall(vim.json.encode, obj)
        return ok
      end

      local function log_skip(reason, data)
        local ok, encoded = pcall(vim.json.encode, data or {})
        local payload = ok and encoded or "<unserializable>"
        local line = string.format("[vue_vtsls] %s | %s", reason, payload)
        local logfile = vim.fn.stdpath "state" .. "/vue_vtsls.log"
        pcall(vim.fn.writefile, { line }, logfile, "a")
        vim.notify(reason, vim.log.levels.WARN)
      end

      local function patch_volar_forwarder()
        return function(client)
          client.handlers["tsserver/request"] = function(_, result, context)
            local ts_clients = vim.lsp.get_clients { bufnr = context.bufnr, name = "vtsls" }
            if #ts_clients == 0 then
              vim.notify("vtsls client not found; vue_lsp forwarding skipped", vim.log.levels.ERROR)
              return
            end
            local ts_client = ts_clients[1]

            -- result is usually { { id, command, payload } } but guard flexible shapes
            local param = result
            if type(result) == "table" and result[1] then param = result[1] end
            local id = param and (param.id or param[1])
            local command = param and (param.command or param[2])
            local payload = param and (param.payload or param[3])
            if not id or not command then
              log_skip("Skip tsserver forward: missing id/command", { param = param })
              return
            end

            if has_function_value(payload) then
              log_skip("Skip tsserver forward: payload contains function (not serializable)", { command = command })
              return
            end
            if not is_json_serializable(payload) then
              log_skip("Skip tsserver forward: payload not JSON-serializable", { command = command })
              return
            end

            -- White-list the command; if unknown, skip to avoid serialization issues
            local allowed = {
               ["typescript.tsserverRequest"] = true,
            }
            if not allowed[command] then
              log_skip("Skip tsserver forward: command not allowed", { command = command })
              return
            end

            ts_client.request(
              "workspace/executeCommand",
              { command = "typescript.tsserverRequest", arguments = { command, payload } },
              function(_, r)
                local body = r and r.body or nil
                if has_function_value(body) then
                  log_skip("Skip tsserver response: body contains function (not serializable)", { command = command })
                  return
                end
                local response_data = { { id, body } }
                if not is_json_serializable(response_data) then
                  log_skip("Skip tsserver response: data not JSON-serializable", { command = command })
                  return
                end
                client:notify("tsserver/response", response_data)
              end,
              context.bufnr
            )
          end
        end
      end

      return astrocore.extend_tbl(opts, {
        config = {
          volar = {
            on_init = patch_volar_forwarder(),
          },
        },
      })
    end,
  },
}

