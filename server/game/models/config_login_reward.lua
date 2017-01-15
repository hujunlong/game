local M = ConfigBase:new()

ConfigLoginReward = M

M:set_origin(config_login_rewards)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local ITEM = 1
local HERO = 2

function M:is_item(  )
  return self.type == ITEM
end

function M:is_hero(  )
  return self.type == HERO
end

function M:get_items( )
  return Tool:map(Tool:split(self.login_rewards, ','), function ( str )
    local t = Tool:split(str, ':')
    return {item_id = tonumber(t[1]), amount = tonumber(t[2])}
  end)
end

function M:get_hero(  )
  local t = Tool:split(self.login_rewards, ':')
  return {config_id = tonumber(t[1]), star = tonumber(t[2])}
end

function M:get_user_info( user )
  local info = {
    uid = self._id,
    day = self.days,
    type = self.type,
    status = user:get_acc_check_in_status(self._id)
  }
  if self:is_item() then
    info.items = self:get_items()
  else
    info.hero = self:get_hero()  
  end
  return info    
end

function M:get_info( user )
  return {acc_check_in_gifts = Tool:map(self:sall(), function ( r )
    return r:get_user_info(user)
  end)
}
end

function M:find_by_days( days )
  return Tool:find(self:sall(), function ( r )
    return r.days == days
  end)
end

function M:give( user )
  if self:is_item() then
    user:add_items(self:get_items())
  else
    user:add_hero(self:get_hero().config_id)
  end
end

M:load()

return M