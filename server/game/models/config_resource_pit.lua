local M = ConfigBase:new()

ConfigResourcePit = M

M:set_origin(config_resource_pits)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:get_info( user )
  local info = {pit_groups = Tool:map(self:sall(), function ( t )
    return {
      uid = t.group,
      pits = Tool:map(Tool:split(t.include, ','), function ( id )
        return tonumber(id)
      end),
      lock = not user.pit_groups[tostring(t.group)],
      resources = t:get_resource(),
      level = t.unlock
    }
  end)}
  return info
end

function M:get_resource(  )
  return {wood = self.wood, food = self.food,  gold = self.gold,  stone = self.stone, ore = self.ore, gem = self.gem}
end

function M:find_by_group( group )
  return Tool:find(self:all(), function ( t )
    return t.group == tonumber(group)
  end)
end

M:load()

return M
