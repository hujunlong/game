
local M = ConfigBase:new()

ConfigMonthlyReward = M

M:set_origin(config_monthly_rewards)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:week_card(  )
  return self:sall()[1]
end

function M:month_card(  )
  return self:sall()[2]
end

function M:get_chest(  )
  if self.__chest then return self.__chest end
  local t = Tool:split(self.chest, ':')
  self.__chest = {item_id = tonumber(t[1]), amount = tonumber(t[2])}
  return self.__chest
end

function M:get_extra_chest(  )
  if self.__extra_chest then return self.__extra_chest end
  local t = Tool:split(self.extra_chest, ':')
  self.__extra_chest = {item_id = tonumber(t[1]), amount = tonumber(t[2])}
  return self.__extra_chest
end

function M:get_checkin_gems(  )
  local t = Tool:split(self.check_in_rewards, ':')
  return tonumber(t[2])
end

M:load()

return M
