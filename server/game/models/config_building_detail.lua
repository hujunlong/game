-- local M = ConfigBase:new()
local M = {}

ConfigBuildingDetail = M

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local share_config = require "share_config"
function M:load()
  local data = share_config.get("config_building_details")
  self.__config = data
end

function M:find_by_id(id)
  for k,v in pairs(self.__config) do
    if v._id == id then
      return v
    end
  end
end

function M:find_by_building_and_level(building_id, level)
  if self.__building_and_levels then
    if not self.__building_and_levels[building_id] then
      return nil
    else  
      return self.__building_and_levels[building_id][level]
    end  
  end
  self.__building_and_levels = {}

  for k,v in pairs(self.__config) do
    self.__building_and_levels[v.building_id] = self.__building_and_levels[v.building_id] or {}
    self.__building_and_levels[v.building_id][v.level] = v
  end
  return self.__building_and_levels[building_id][level]
end

-- function M:select_levels(conf, building_id)
--   return Tool:select(conf.__config, function ( r )
--     return r.building_id == building_id
--   end)
-- end

function M:get_resources( conf  )
  -- if self.__resources then return self.__resources end
  -- self.__resources = {gold = tonumber(self.gold), wood = tonumber(self.wood), stone = tonumber(self.stone), food = tonumber(self.food)}
  -- return self.__resources
  return {gold = tonumber(conf.gold), wood = tonumber(conf.wood), stone = tonumber(conf.stone), food = tonumber(conf.food)}
end

function M:get_unlock_conditions( conf )
  if conf.unlock == 0 then
    return {}
  else
    return Tool:map(Tool:split(conf.unlock, ','), function ( s )
      local t = Tool:split(s, ':')
      return {building_id = math.floor(t[1]), level = math.floor(t[2])}
    end)
  end
  -- if self.__unlock then return self.__unlock end
  -- if self.unlock == 0 then
  --   self.__unlock = {}
  --   return self.__unlock
  -- end
  -- self.__unlock = Tool:map(Tool:split(self.unlock, ','), function ( s )
  --   local t = Tool:split(s, ':')
  --   return {building_id = math.floor(t[1]), level = math.floor(t[2])}
  -- end)
  -- return self.__unlock
end

function M:get_rewards( conf )
  if conf.rewards == 0 then return {} end

  local ret = {}
  Tool:map(Tool:split(conf.rewards, ','), function ( str )
    local t = Tool:split(str, ':')
    local item_id = tonumber(t[1]) 
    local amount = tonumber(t[2])
    table.insert(ret, {item_id = item_id, amount = amount})
  end)
  return ret

  -- self.__rewards = {}
  -- Tool:map(Tool:split(self.rewards, ','), function ( str )
  --   local t = Tool:split(str, ':')
  --   local item_id = tonumber(t[1]) 
  --   local amount = tonumber(t[2])
  --   table.insert(self.__rewards, {item_id = item_id, amount = amount})
  -- end) 
  -- return self.__rewards
end

function M:get_res_rewards( conf )
  if conf.resource_rewards == 0 then return {} end

  local ret = {}
  Tool:map(Tool:split(conf.resource_rewards, ','), function ( str )
    local t = Tool:split(str, ':')
    local type = t[1]
    local amount = tonumber(t[2])
    ret[type] = amount
  end)
  return ret

  -- self.__resource_rewards = {}
  -- Tool:map(Tool:split(self.resource_rewards, ','), function ( str )
  --   local t = Tool:split(str, ':')
  --   local type = t[1]
  --   local amount = tonumber(t[2])
  --   self.__resource_rewards[type] = amount
  -- end)
  -- return self.__resource_rewards
end

return M
