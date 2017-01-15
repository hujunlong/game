local M = ConfigBase:new()

ConfigCityOverview = M

M:set_origin(config_overviews)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:vip(  )
  return self:all()[61301]
end

function M:research(  )
  return self:all()[61302]
end

function M:union(  )
  return self:all()[61303]
end

function M:buff(  )
  return self:all()[61304]
end

function M:rate( num, attr )
  assert(self[attr] ~= 0)
  return math.floor(num / self[attr] * 100)
end

M:load()

return M
