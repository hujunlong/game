local M = ConfigBase:new()

ConfigOnlineRewardsRule = M

M:set_origin(config_online_rewards_rules)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:find_by_times( times )
  return Tool:find(self:sall(), function ( r )
    return r.arrange == times
  end)
end

function M:rand_time(  )
  return Tool:rand_range(self.cd_time_min, self.cd_time_max)
end

M:load()

return M
