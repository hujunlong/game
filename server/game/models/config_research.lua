local M = {}

ConfigResearch = M

-- M:set_origin(config_researches)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local share_config = require "share_config"

function M:load()
  local data = share_config.get("config_researches")
  self.__config = data
end

function M:find_by_id(id)
  for k,v in pairs(self.__config) do
    if v._id == id then
      return v
    end
  end
end

function M:get_resources(config, level )
  return {
    gold = M:get_gold_func(config)(level), 
    food = M:get_food_func(config)(level), 
    wood = M:get_wood_func(config)(level), 
    stone = M:get_stone_func(config)(level), 
    ore = M:get_ore_func(config)(level)
  }
end

function M:get_gold_func( config )
  return loadstring("return function (n) return "..tostring(config.gold) .." ; end")()
end

function M:get_food_func( config )
  return loadstring("return function (n) return "..tostring(config.food).." ; end")()
end

function M:get_wood_func( config )
  return loadstring("return function (n) return "..tostring(config.wood).." ; end")()
end

function M:get_stone_func( config )
  return loadstring("return function (n) return "..tostring(config.stone).." ; end")()
end

function M:get_ore_func( config  )
  return loadstring("return function (n) return "..tostring(config.ore).." ; end")()
end

function M:get_effect_func( config )
  return loadstring("return function (n) return "..tostring(Tool:split(config.stats, ':')[2]).." ; end")()
end

function M:get_effects (config, level )
  local e = {}
  level = level or 0
  e[tonumber(Tool:split(config.stats, ':')[1])] = M:get_effect_func(config)(level)
  return e
end

function M:get_time_func(config)
  return loadstring("return function (n) return "..tostring(config.time).." ; end")()
end

function M:get_time(config, level)
  local f = M:get_time_func(config) 
  return f(level)
end

function M:get_require_building_level( level )
  local build_level = tonumber(Tool:split(self.academy_level, '-')[1])
  if level > 1 then
    build_level = build_level + (level - 1) * self.per_level
  end
  return build_level
end

function M:get_max_level()
  return self.level
end

-- M:load()

return M
