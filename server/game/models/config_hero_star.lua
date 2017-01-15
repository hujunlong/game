local M = ConfigBase:new()

ConfigHeroStar = M

M:set_origin(config_hero_stars)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:find_by_star( star )
  return Tool:find(self:all(), function ( r )
    return r.star == star
  end)
end

M:load()

return M

