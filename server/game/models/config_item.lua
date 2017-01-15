local M = {}

ConfigItem = M

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:load(  )
  self.__all = Tool:concat({
    ConfigBuffItem:all(), 
    ConfigFunctionItem:all(), 
    ConfigResourceItem:all(), 
    ConfigEquipment:all(), 
    ConfigSpeedItem:all(), 
    ConfigSoulItem:all(),
    ConfigChestItem:all(),
    ConfigVipItem:all()
  })
end

function M:all(  )
  return self.__all
end

function M:find_by_id( id )
  if self.__table then return self.__table[id] end
  self.__table = {}
  for k,v in pairs(self:all()) do
    self.__table[v._id] = v
    v.get_shops = M.get_shops
  end
  return self.__table[id]
end

function M.get_shops (self)
  if self.shop == '0' or self.shop == 0 then return {} end
  self.__shops = {}
  Tool:map(Tool:split(self.shop, ','), function ( str )
    t = Tool:split(str, ':')
    self.__shops[tonumber(t[1])] = {type = tonumber(t[2]), amount = tonumber(t[3])}
  end)
  return self.__shops
end  

M:load()

return M
