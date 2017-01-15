local M = ConfigBase:new()

ConfigVipItem = M

M:set_origin(config_vip_items)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:used( user, opts )
  opts = opts or {}
  opts.amount = opts.amount or 1
  user:add_vip_bless_time(self.time * opts.amount)
  return nil, user:get_vip_info()
end

M:load()

return M
