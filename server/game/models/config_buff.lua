local M = ConfigBase:new()

ConfigBuff = M

M:set_origin(config_buffs)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:find_all_temple_buff()
  if self.__temple_buff then return self.__temple_buff end
  self.__temple_buff = {}
  for k,v in pairs(self:all()) do
    if v.type == 2 then
        table.insert(self.__temple_buff, v)
    end
  end
  return self.__temple_buff
end

function M:find_buff_by_id(id)
  if self.__BUFFS then return self.__BUFFS[id] end
  self.__BUFFS = {}
  for k,v in pairs(self:all()) do
    self.__BUFFS[v._id] = v
  end
  return self.__BUFFS[id]
end

M:load()

return M
