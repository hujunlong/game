
local M = {}
config_variable = M

function M.get(key)
  return M.variables[key]
end

function M.init()
  M.variables = {}
  for k, v in pairs(config_func_variable) do
    M.variables[v.key] = v.value
  end
end

M.init()

return M
