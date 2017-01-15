
require "config_alliance_researches"

local M = ConfigBase:new()

ConfigUnionResearch = M

M:set_origin(config_alliance_researches)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:get_gold(level)
  if not self.__get_gold then
    self.__get_gold = loadstring("return function (n) return " .. tostring(self.gold) .. " ; end")()
  end

  return self.__get_gold(level)
end

function M:get_food(level)
  if not self.__get_food then
    self.__get_food = loadstring("return function (n) return " .. tostring(self.food) .. " ; end")()
  end

  return self.__get_food(level)
end

function M:get_wood(level)
  if not self.__get_wood then
    self.__get_wood = loadstring("return function (n) return " .. tostring(self.wood) .. " ; end")()
  end

  return self.__get_wood(level)
end

function M:get_stone(level)
  if not self.__get_stone then
    self.__get_stone = loadstring("return function (n) return " .. tostring(self.stone).. " ; end")()
  end

  return self.__get_stone(level)
end

function M:get_ore(level)
  if not self.__get_ore then
    self.__get_ore = loadstring("return function (n) return " .. tostring(self.ore) .. " ; end")()
  end

  return self.__get_ore(level)
end

function M:get_exp(level)
  if not self.__get_exp then
    self.__get_exp = loadstring("return function (n) return " .. tostring(self.exp) .. " ; end")()
  end

  return self.__get_exp(level)
end

function M:max_level()
  return self.level
end

function M:exp_per_time()
  return self.exp_up
end

function M:get_upgrade_time(level)
  if not self.__get_upgrade_time then
    self.__get_upgrade_time = loadstring("return function (n) return " .. tostring(self.time) .. " ; end")()
  end

  return self.__get_upgrade_time(level)
end

function M:get_effect_func(  )
  self.__effect_func = self.__effect_func or loadstring("return function (n) return "..tostring(Tool:split(self.stats, ':')[2]).." ; end")()
  return self.__effect_func
end

function M:get_effects ( level )
  local e = {}
  level = level or 0
  e[tonumber(Tool:split(self.stats, ':')[1])] = self:get_effect_func()(level)
  return e
end

function M:get_effect_name()
  local id = tonumber(Tool:split(self.stats, ':')[1])
  return ConfigStat:get_name_by_id(id)
end

M:load()

return M
