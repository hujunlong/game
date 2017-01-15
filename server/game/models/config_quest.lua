local M = {}

ConfigQuest = M

-- M:set_origin(config_quests)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local share_config = require "share_config"

function M:load()
  local data = share_config.get("config_quests")
  self.__config = data
  self:init_main_quests()
end

function M:find_by_id(id)
  for k,v in pairs(self.__config) do
    if v._id == id then
      return v
    end
  end
end

-- check
function M:get_reward( conf )
  return {gold = conf.gold, food = conf.food, wood = conf.wood, stone = conf.stone, ore = conf.ore, gem = conf.gem}
end

function M:convert_items_col(conf, cache_name, col )
  local ret = {}
  if tostring(conf[col]) == '0' then return ret end
  for i,str in ipairs(Tool:split(conf[col], ',')) do
    local t = Tool:split(str, ':')
    table.insert(ret, {item_id = tonumber(t[1]), amount = tonumber(t[2])})
  end
  return ret
end

--check
function M:get_items( conf )
  return M:convert_items_col(conf, '__items', 'item')
end

-- check
function M:get_battle_unit(config)
  if not config.battle_unit or config.battle_unit == 0 then return {} end

  local ret = {}
  local t = Tool:split(config.battle_unit, ',')
  for k, v in pairs(t) do
    local t2 = Tool:split(v, ':')
    table.insert(ret, {_id = tonumber(t2[1]), amount = tonumber(t2[2])})
  end
  return ret
end

-- check
function M:get_target( conf )
  local ret = {}
  local t = Tool:split(conf.target, ':')
  if conf.target_type == QuestConst.BUILDING then
    ret = {
      type = t[1],
      building_id = tonumber(t[2]),
      level = tonumber(t[3]),
      amount = tonumber(t[4])
    }
  elseif conf.target_type == QuestConst.BUILD then
    ret = {
      type = t[1],
      building_id = tonumber(t[2]),
      amount = tonumber(t[3])
  }  
  elseif conf.target_type == QuestConst.RECRUIT_HERO then
    ret = {
      type = t[1],
      amount = tonumber(t[2]),
  }  
  elseif conf.target_type == QuestConst.HERO_LEVEL_UP then
    ret = {
      type = t[1],
      level = tonumber(t[2]),
  }
  elseif conf.target_type == QuestConst.HERO_RANK_UP then
    ret = {
      type = t[1],
      amount = tonumber(t[2]),
      level = tonumber(t[3]),
  }
  elseif conf.target_type == QuestConst.HERO_STAR then
    ret = {
      type = t[1],
      amount = tonumber(t[2]),
      level = tonumber(t[3]),
  }
  elseif conf.target_type == QuestConst.EQUIPMENT_LEVEL_UP then
    ret = {
      type = t[1],
      amount = tonumber(t[2]),
      level = tonumber(t[3]),
  }
  elseif conf.target_type == QuestConst.OFFICER then
    ret = {
      type = t[1],
      amount = tonumber(t[2])
  }
  elseif conf.target_type == QuestConst.HERO_PVP then
    ret = {
      type = t[1],
      amount = tonumber(t[2])
  }
  elseif conf.target_type == QuestConst.TRAIN or conf.target_type == QuestConst.TRAINING then
    ret = {
      type = t[1],
      army_id = tonumber(t[2]),
      amount = tonumber(t[3])
  }
  elseif conf.target_type == QuestConst.RESEARCH then
    ret = {
      type = t[1],
      research_id = tonumber(t[2]),
      amount = tonumber(t[3])
  }
  elseif conf.target_type == QuestConst.KILL_MONSTER then
    ret = {
      type = t[1],
      amount = tonumber(t[2])
  }
  elseif conf.target_type == QuestConst.PVP_VICTORY then
    ret = {
      type = t[1],
      amount = tonumber(t[2])
  }
  elseif conf.target_type == QuestConst.EVENT_TARGET then
    ret = {
      type = t[1],
      event_id = tonumber(t[2])
  }
  elseif conf.target_type == QuestConst.GATHER_GOLD or 
    conf.target_type == QuestConst.GATHER_FOOD or 
    conf.target_type == QuestConst.GATHER_WOOD or
    conf.target_type == QuestConst.GATHER_ORE or
    conf.target_type == QuestConst.GATHER_GEM or
    conf.target_type == QuestConst.GATHER_STONE or
    conf.target_type == QuestConst.FOOD_OUTPUT or
    conf.target_type == QuestConst.WOOD_OUTPUT or
    conf.target_type == QuestConst.STONE_OUTPUT or
    conf.target_type == QuestConst.ORE_OUTPUT or
    conf.target_type == QuestConst.TOTAL_TRAIN or
    conf.target_type == QuestConst.TOTAL_DIED or 
    conf.target_type == QuestConst.TOTAL_RESEARCH or 
    conf.target_type == QuestConst.TOTAL_EXPLORE or
    conf.target_type == QuestConst.CHAT or
    conf.target_type == QuestConst.WEEK_ATTACK_RES or
    conf.target_type == QuestConst.WEEK_MARCH_DISTANCE or
    conf.target_type == QuestConst.WEEK_SIEGE or
    conf.target_type == QuestConst.TOTAL_MARCH_SPEED or
    conf.target_type == QuestConst.TOTAL_PVP_VICTORY or
    conf.target_type == QuestConst.TOTAL_VALUATE_S or
    conf.target_type == QuestConst.TOTAL_VALUATE_A or
    conf.target_type == QuestConst.MARCH_OVER_THAN or
    conf.target_type == QuestConst.COMPLET_EACHIEVEMENT 
    then
    ret = {
      type = t[1],
      amount = tonumber(t[2])
  }
  elseif conf.target_type == QuestConst.SERVER_CITY_HALL then
      ret = {
        type = t[1],
        config_id = tonumber(t[2]),
        level = tonumber(t[3])
  }
  elseif conf.target_type == QuestConst.QUICK_UPGRADE_BUILDING then
      ret = {
        type = t[1],
        config_id = tonumber(t[2]),
        level = tonumber(t[3]),
        amount = tonumber(t[4]),
    }    
  end
  return ret
end

--check
function M:check(conf, quest, user, target )
  local target_t = {}
  local orignal =quest.cur
  if target then
    target_t = Tool:split(target, ':')
  end
  if target and M:get_target(conf).type ~= target_t[1] then
    return false
  end

  if conf.target_type == QuestConst.BUILDING then
    quest.max = M:get_target(conf).amount
    quest.cur = user:get_building_highest_level_count(M:get_target(conf).building_id, M:get_target(conf).level)
    if quest.max <= quest.cur then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.BUILD then
    quest.max = M:get_target(conf).amount
    quest.cur = user:get_building_count(M:get_target(conf).building_id)
    if quest.max <= quest.cur then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.RECRUIT_HERO then
    quest.max = M:get_target(conf).amount
    quest.cur = user:get_hero_count()
    if quest.max <= quest.cur then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.HERO_LEVEL_UP then
    quest.max = M:get_target(conf).level
    quest.cur = user:get_max_hero_level()
    if quest.max <= quest.cur then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.HERO_RANK_UP then
    quest.max = M:get_target(conf).amount
    quest.cur = user:get_quality_hero_count(M:get_target(conf).level)
    if quest.max <= quest.cur then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.HERO_STAR then
    quest.max = M:get_target(conf).amount
    quest.cur = user:get_star_hero_count(M:get_target(conf).level)
    if quest.max <= quest.cur then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.EQUIPMENT_LEVEL_UP then
    quest.max = M:get_target(conf).amount
    quest.cur = user:get_equip_level_count(M:get_target(conf).level)
    if quest.max <= quest.cur then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.OFFICER then
    quest.max = M:get_target(conf).amount
    quest.cur = #user.poss
    if quest.max <= quest.cur then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.HERO_PVP then
    quest.max = M:get_target(conf).amount
    quest.cur = user.hero_pvp_count
    if quest.max <= quest.cur then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.TRAIN then
    quest.max = M:get_target(conf).amount
    if tonumber(target_t[2]) == M:get_target(conf).army_id then
      quest.cur = quest.cur + tonumber(target_t[3])
      if quest.max <= quest.cur then
        quest:set_reward()
      end
    end
  elseif conf.target_type == QuestConst.RESEARCH then
    quest.max = M:get_target(conf).amount
    quest.cur = user:get_research_level(M:get_target(conf).research_id)
    if quest.max <= quest.cur then
      quest.cur = quest.max
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.KILL_MONSTER then
    quest.max = M:get_target(conf).amount
    quest.cur = user.kill_monster_count
    if quest.max <= quest.cur then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.PVP_VICTORY then
    quest.max = M:get_target(conf).amount
    quest.cur = user.pvp_win_count
    if quest.max <= quest.cur then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.EVENT_TARGET then
    return "PENDING"
  elseif conf.target_type == QuestConst.COMPLET_EACHIEVEMENT then
    quest.max = M:get_target(conf).amount
    local finished = user:get_finish_achivement_count()
    local total = M:get_achviment_total()
    quest.cur = math.floor(finished/total * 100)
    if quest.max <= quest.cur then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.SERVER_EXPLORE then
    local is_first = game_cmd:exc_server_cmd("server_info_mgr", "assert_first_explore", user._id)
    if is_first then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.SERVER_LOSTTEMPLE then
    local is_first = game_cmd:exc_server_cmd("server_info_mgr", "assert_first_vist_temple", user._id)
    if is_first then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.SERVER_GATHEROVER then
    local is_first = game_cmd:exc_server_cmd("server_info_mgr", "assert_first_gatherover", user._id)
    if is_first then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.MARCH_OVER_THAN  then
    quest.max = M:get_target(conf).amount
    quest.cur = tonumber(target_t[2] or 0)
    if quest.max <= quest.cur then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.GATHER_GOLD or 
    conf.target_type == QuestConst.GATHER_FOOD or 
    conf.target_type == QuestConst.GATHER_WOOD or
    conf.target_type == QuestConst.GATHER_ORE or
    conf.target_type == QuestConst.GATHER_GEM or
    conf.target_type == QuestConst.GATHER_STONE or
    conf.target_type == QuestConst.TOTAL_TRAIN or
    conf.target_type == QuestConst.TOTAL_DIED or
    conf.target_type == QuestConst.TOTAL_RESEARCH or 
    conf.target_type == QuestConst.TOTAL_EXPLORE or
    conf.target_type == QuestConst.CHAT or
    conf.target_type == QuestConst.WEEK_ATTACK_RES or
    conf.target_type == QuestConst.WEEK_MARCH_DISTANCE or
    conf.target_type == QuestConst.WEEK_SIEGE or
    conf.target_type == QuestConst.TOTAL_MARCH_SPEED or
    conf.target_type == QuestConst.TOTAL_PVP_VICTORY or
    conf.target_type == QuestConst.TOTAL_VALUATE_S or
    conf.target_type == QuestConst.TOTAL_VALUATE_A 
    then
      quest.max = M:get_target(conf).amount
      quest.cur = quest.cur + tonumber(target_t[2] or 0)
      if quest.max <= quest.cur then
        quest:set_reward()
      end
  elseif conf.target_type == QuestConst.SERVER_CITY_HALL then
    quest.max = 1
    local is_server_first = game_cmd:exc_server_cmd("server_info_mgr", "assert_first_build" ,user:get_uid(), target_t[2], target_t[3])
    if tostring(M:get_target(conf).config_id) == target_t[2] and tostring(M:get_target(conf).level) == target_t[3] and is_server_first then
      quest.cur = 1
    end
    if quest.max <= quest.cur then
      quest:set_reward()
    end   
  elseif conf.target_type == QuestConst.JOIN_ALLIANCE then
    quest.max = 1
    if user:has_union() then
      quest.cur = 1
    end      
    if quest.max <= quest.cur then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.QUICK_UPGRADE_BUILDING then
    quest.max = M:get_target(conf).amount
    quest.cur = user:get_building_count_greater(M:get_target(conf).config_id, M:get_target(conf).level)
    if quest.max <= quest.cur then
      quest:set_reward()
      quest.cur = quest.max
    end
  elseif conf.target_type == QuestConst.FOOD_OUTPUT then
    quest.max = M:get_target(conf).amount
    quest.cur = user:get_current_buildings_output(BuildingConst.BUILDING.Farm)
    if quest.max <= quest.cur then
      quest:set_reward()
    end 
  elseif conf.target_type == QuestConst.WOOD_OUTPUT then
    quest.max = M:get_target(conf).amount
    quest.cur = user:get_current_buildings_output(BuildingConst.BUILDING.Sawmill)
    if quest.max <= quest.cur then
      quest:set_reward()
    end  
  elseif conf.target_type == QuestConst.STONE_OUTPUT then
    quest.max = M:get_target(conf).amount
    quest.cur = user:get_current_buildings_output(BuildingConst.BUILDING.Quarry)
    if quest.max <= quest.cur then
      quest:set_reward()
    end  
  elseif conf.target_type == QuestConst.ORE_OUTPUT then
    quest.max = M:get_target(conf).amount
    quest.cur = user:get_current_buildings_output(BuildingConst.BUILDING.Smelter)
    if quest.max <= quest.cur then
      quest:set_reward()
    end
  elseif conf.target_type == QuestConst.SEND_MAIL then
    quest.max = 1
    quest.cur = user.send_mail_count
    if quest.max <= quest.cur then
      quest:set_reward()
    end
  else
    quest.max = 1
  end

  if quest.cur > orignal and not quest:is_reward() then
    user:send_push({quests = {quest:get_info()}})
  end

end

function M:init_main_quests()
  local orders = {}

  for _, v in pairs( self.__config ) do
    if tonumber(v.order) > 0 then
      table.insert(orders, { id = v._id, order = tonumber(v.order)})
    end
  end

  table.sort(orders, function (a, b)
    return a.order < b.order
  end)

  local quests = {}
  local pre_uid
  for i, v in pairs(orders) do
    if pre_uid == nil then
      quests.start = v.id
    else
      quests[pre_uid] = v.id
    end
    
    pre_uid = v.id
  end

  self.__main_quests = quests
end

-- check
function M:get_main_quest(pre_uid)
  local id = self.__main_quests[pre_uid or "start"]
  return M:find_by_id(id)
end

-- check
function M:get_guide(conf)
  return Tool:map(Tool:split(self.guide, ':'), function ( str )
    return tonumber(str)
  end)
  -- if self.__guide then return self.__guide end
  -- self.__guide = Tool:map(Tool:split(self.guide, ':'), function ( str )
  --   return tonumber(str)
  -- end) 
  -- return self.__guide
end


local MAIN_QUEST_TYPE = 1
local UNION_QUEST_TYPE = 2

-- check
function M:select_union(  )
  return Tool:select(self.__config, function ( r )
    return M:is_union(r)
  end)
end

-- check
function M:is_union( config )
  return config.type == UNION_QUEST_TYPE
end

-- check
function M:is_main( config )
  return config.type == MAIN_QUEST_TYPE
end

-- check
function M:get_achviment_total()
  local total_number = 0
  for k, v in pairs(self.__config) do
    if v.type == QuestConst.ACHIVEMENT then
      total_number = total_number + 1
    end
  end
  return total_number
end

function M:get_achviment_total_by_qulity()
  local total_number = 0
  local res = {}
  for k, v in pairs(self.__config) do
    if v.type == QuestConst.ACHIVEMENT then
      if not res[v.quality] then
        res[v.quality] = 0
      end
      res[v.quality] = res[v.quality] + 1
    end
  end
  return res
end

-- M:load()
-- M:init_main_quests()

return M
