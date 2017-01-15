local M = ConfigBase:new()

ConfigResourceItem = M

M:set_origin(config_resource_items)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:used( user, opts )
  local res = {}
  opts = opts or {}
  opts.amount = opts.amount or 1
  res[self.resource] = self:get_func().amount * opts.amount
  user:add_resources(res)
  return user:get_resources_info(), {reward = {resource = res}}
end

function M:get_func(  )
  local t = Tool:split(self.func, ':')
  return {type = tonumber(t[1]), amount = tonumber(t[2])}
end

M:load()

return M
