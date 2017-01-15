local M = {}

ConfigMonster = M

-- M:set_origin(config_monsters)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local share_config = require "share_config"

function M:load()
  local data = share_config.get("config_monsters")
  self.__config = data
end

function M:find_by_id(id)
  for k,v in pairs(self.__config) do
    if v._id == id then
      return v
    end
  end
end

function M:find_by_type_and_level (type, level)
  return Tool:find(self.__config, function ( r )
    return r.belong == type and r.level == level
  end) 

end

-- check
-- function M:is_boss( conf )
--   return conf.boss == 1
-- end

-- check
function M:get_attack(conf)
  return Tool:rand_range(conf.attack_min, conf.attack_max)
end

-- check
function M:get_restrains(conf)
  return {{id = conf.restrain_1, rate = conf.revise_1}, {id = conf.restrain_2, rate = conf.revise_2}}
end

-- check
function M:get_ais( conf )
  return {{ id = conf.target_1, rate = conf.target_1_oods}, { id = conf.target_2, rate = conf.target_2_odds}}
end

-- check
function M:get_back_res(conf, amount )
  return Tool:multi({gold = conf.gold, food = conf.food, wood = conf.wood, stone = conf.stone, ore = conf.ore}, amount / 2)
end

function M:get_resources(conf, amount )
  return Tool:multi({gold = conf.gold, food = conf.food, wood = conf.wood, stone = conf.stone, ore = conf.ore}, amount) 
end

function M:get_cure_resources(conf, amount )
  return Tool:multi({gold = conf.gold, food = conf.food, wood = conf.wood, stone = conf.stone, ore = conf.ore}, amount * conf.cure_gold / 100 )
end

function M:cal_might( armies )
  return math.floor(Tool:sum(armies, function ( a )
      return ConfigMonster:find_by_id(a._id or a.config_id).might * a.amount
  end))
end
-- M:load()

return M
