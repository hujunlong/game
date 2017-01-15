local M = ConfigBase:new()

ConfigHero = M

M:set_origin(config_heroes)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end


function M:get_skill_ids () 
  if self.__skill_ids then return self.__skill_ids end
  self.__skill_ids = Tool:map(Tool:split(self.skill, ','), function ( id )
    return tonumber(id)
  end)
  return self.__skill_ids
end

function M:get_equipments () 
  if self.__equipments then return self.__equipments end
  self.__equipments = {}
  for i=1,self.max_quality do
    self.__equipments[i] = Tool:map(Tool:split(self["equipment_"..i], ','), function ( id )
      return tonumber(id)
    end)
  end
  return self.__equipments
end

function M:get_skill_unlock () 
  if self.__skill_unlock then return self.__skill_unlock end
  self.__skill_unlock = {}
  for k,str in pairs(Tool:split(self.skill_unlock, ',')) do
    local t = Tool:split(str, ':')
    self.__skill_unlock[tonumber(t[1])] = tonumber(t[2])
  end
  return self.__skill_unlock
end  

M:load()

return M

