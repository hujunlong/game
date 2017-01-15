local M = ConfigBase:new()

ConfigDailyReward = M

M:set_origin(config_daily_rewards)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:get_rewards(  )
  if self.__rewards then return self.__rewards end
  self.__rewards = Tool:map(Tool:split(self.daily_rewards, ','), function ( item_id )
    return tonumber(item_id)
  end)
  return self.__rewards
end

function M:find_by_days( days )
  return Tool:find(self:sall(), function ( r )
    return r.days == days
  end)
end

function M:rand( days )
  local r = self:find_by_days(days)
  if not r then return end
  return {item_id = Tool:rand(r:get_rewards()), amount = r.quantity}
end

M:load()

return M