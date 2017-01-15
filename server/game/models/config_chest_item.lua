local M = ConfigBase:new()

ConfigChestItem = M

M:set_origin(config_chest_items)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:used( user, opts )
  opts = opts or {}
  opts.amount = opts.amount or 1
  local items = self:get_items()
  for i,v in ipairs(items) do
    v.amount = v.amount * opts.amount
  end
  user:add_items(items)
  local msg = Tool:merge({
    user:get_items_info(),
    {reward = {items = items}}
  })
  return nil, msg
end

function M:get_items(  )
  return Tool:map(Tool:split(self.items, ','), function ( str )
    local t = Tool:split(str, ':')
    return {item_id = tonumber(t[1]), amount = tonumber(t[2])}
  end)  
end

M:load()

return M
