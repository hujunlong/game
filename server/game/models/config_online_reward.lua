local M = ConfigBase:new()

ConfigOnlineReward = M

M:set_origin(config_online_rewards)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:get_rewards(  )
  if self.__rewards then return self.__rewards end
  self.__rewards = Tool:map(Tool:split(self.rewards, ','), function ( str )
    local t = Tool:split(str, ":")
    local item_id = tonumber(t[1])
    local amount = tonumber(t[2])
    return {item_id = item_id, amount = amount}
  end) 
  return self.__rewards
end

function M:rand_rewards( )
  return Tool:rand(self:get_rewards())
end

function M:find_by_level( level )
  return Tool:find(self:sall(), function ( r )
    return r.level == level
  end)
end

function M:get_low(  )
  self.__low = self:find_by_level(1) or self.__low
  return self.__low
end

function M:get_mid(  )
  self.__mid = self:find_by_level(2) or self.__mid
  return self.__mid
end

function M:get_high(  )
  self.__high = self:find_by_level(3) or self.__high
  return self.__high
end

M:load()

return M
