local M = ConfigBase:new()

ConfigVip = M

M:set_origin(config_vips)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:get_max_level(  )
  if self.__max_level then return self.__max_level end
  self.__max_level = Tool:max_by(self:sall(), function ( cv )
    return cv.level
  end).level
  return self.__max_level
end

function M:find_by_level( level )
  if self.__levels then return self.__levels[level] end
  self.__levels = {}
  for k,v in pairs(self:all()) do
      self.__levels[v.level] = v
  end
  return self.__levels[level]
end

function M:get_effects(  )
  return self:convert_effects('__effects', 'buffs')
end

function M:get_common_effects(  )
  return self:convert_effects('__common_effects', 'rights')
end

M:load()

return M
