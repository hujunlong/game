local M = ConfigBase:new()

ConfigBuilding = M

M:set_origin(config_buildings)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:get_pit(  )
  for k,cp in pairs(ConfigPit:all()) do
    if Tool:include(cp:get_buildings(), self._id) then
      return cp._id
    end  
  end
  return 0
end

function M:get_arms ()
  return Tool:map(Tool:split(self.train, ','), function ( i )
    return tonumber(i)
  end)
end  

function M:get_arms_info (opened)
  local info = {}
  Tool:map(self:get_arms(), function ( i )
    local ci = ConfigMonster:find_by_id(i)
    if ci then
      table.insert(info, {
        uid = ci._id,
        level = ci.level,
        category = ci.category,
        lock = not opened[tostring(ci._id)]
      })
    end  
  end)
  return info
end

function M:get_buff(  )
  if self.__buff then return self.__buff end
  self.__buff = {}
  if self.buff == 0 then return self.__buff end
  local t = Tool:split(self.buff, ':')
  self.__buff[t[1]] = tonumber(t[2])
  return self.__buff
end

function M:get_buff_gems( level )
  return math.ceil(self:get_buff_gems_func()(level))
end

function M:get_buff_gems_func(  )
  if self.__buff_gems_func then return self.__buff_gems_func end
  self.__buff_gems_func = loadstring("return function (n) return "..self.buff_gem.." ; end")()
  return self.__buff_gems_func
end

M:load()

return M

