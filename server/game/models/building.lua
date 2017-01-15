
local M = {}

local DEFAULT = {
  _id = 0,
  config_id = 0, -- 建筑的配置ID
  pit = 0, -- 建筑的坑位号
  level = 0, -- 初始等级
  start_time = 0, -- 建筑任务开始时间(建造，升级，招兵等等，同一时间只能有一个任务存在)
  finish_time = 0, -- 建筑任务结束时间
  work = 0, -- 正在执行的内容（如果是招兵就是兵种ID， 如果是科技就是科技ID）
  status = 0, -- 状态（0 空闲 ）
  train = 0, -- 训练的兵种数量
  armies = {}, -- 建筑中的士兵 [_id: Number, amount: Number]
  event_id = '', -- 事件ID
  updated_time = 0, -- 上次更新产出资源时间
  amount = 0, -- 拥有的资源数量
  speed = {start_time = 0, finish_time = 0, num = 0, item_id = 18016},
  help_times = 3,
  can_help = false,
  hit = false,
  has_survice = false,
  work_time = 0,
  survive = {} -- 轻伤兵
}

Building = M

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o:addons()
  return o
end

function M:factory( params, db_id )
  Tool:add_merge({params, DEFAULT})
  if not params._id or params._id == 0 then
    params._id = db_id
  end
  return self:new(params)
end

function M:remove(  )
  Tool:remove(self:get_user().buildings, self)
end

function M:get_uid(  )
  return tostring(self._id)
end

function M:get_info( )
  return {
    uid = self:get_uid(),
    config_id = self.config_id,
    level = self.level,
    status = self.status,
    work = self.work,
    start_time = self.start_time,
    finish_time = self.finish_time,
    specs = self:get_spec_info(),
    train = self.train,
    speed = self:get_speed_info(),
    can_help = self.can_help,
    once_train = self:get_once_train(),
    max_train = self:get_max_train(),
    has_survice = self.has_survice,
    survive = self:get_survive_info(),
    work_time = self.work_time,
    speed_up_gems = self:get_speed_up_gems(),
  }
end

function M:get_speed_info(  )
  self.speed.item_id = self:get_config().items
  return self.speed
end

function M:get_speed_up_gems(  )
  return self:get_buff_gems()
end

function M:get_spec_info( )
  return {}
end

function M:get_config(  )
  self.__config = self.__config or ConfigBuilding:find_by_id(self.config_id)
  return self.__config
end

function M:get_once_train()
  if self:get_detail() then
    return tonumber(self:get_detail().max_training + self:get_user():get_TrainingVolume_effect())
  else
    return 0
  end  
end


function M:is_max_level(  )
  return self.level >= self:get_config().max_level
end

function M:add_armies(  )
  self.status = BuildingConst.BUILDING_STATUS.COLLECT
  self:get_user():add_armies(self.armies)
  user:check_quests("train:"..ConfigMonster:find_by_id(self.armies[1]._id).category..":"..self.armies[1].amount)
end

function M:upgrade( )
  self.level = self.level + 1
  self.can_help = false
  self:get_user():refresh_level()
  self:set_idle()
  self.work = 0
  self.finish_time = 0
  self.start_time = 0
  self.updated_time = os.time()
  local user = self:get_user()
  local resource = ConfigBuildingDetail:get_resources(self:get_next_level_detail())
  user.consume_wood = user.consume_wood + (resource.wood or 0)
  user.consume_stone = user.consume_stone + (resource.stone or 0)
  user:update_building_score()

  user:building_remove_help(self._id)
  
  game_cmd:exc_event_cmd("del", self.event_id)
	local push_msg	
  if self.config_id == BuildingConst.BUILDING.HeroHall then
    push_msg = user:get_poss_info()
  elseif self.config_id == BuildingConst.BUILDING.House then
    push_msg = {users = {{uid = user:get_uid(), max_train = user:get_max_train_count()}}}
  elseif self.config_id == BuildingConst.BUILDING.Barrack then
    push_msg = {}
    user:open_arm(self:get_detail().barracks_unlock_units)
    for k,building in pairs(user:select_building(BuildingConst.BUILDING.House)) do
      push_msg.buildings = push_msg.buildings or {}
      table.insert(push_msg.buildings, building:get_info())
    end
    push_msg.users = {{uid = user:get_uid(), max_train = user:get_max_train_count()}}
  elseif self.config_id == BuildingConst.BUILDING.Wall then
    user:open_arm(self:get_detail().wall_unlock_units)
    push_msg = {users = {{uid = user:get_uid(), max_train = user:get_max_train_count()}}}
  elseif self.config_id == BuildingConst.BUILDING.Factory then
    user:open_arm(self:get_detail().factory_unlock_units)
    user:update_city_life()
    push_msg = user:get_city_info()
    for k,building in pairs(user:select_building(BuildingConst.BUILDING.House)) do
      push_msg.buildings = push_msg.buildings or {}
      table.insert(push_msg.buildings, building:get_info())
    end
    push_msg.users = {{uid = user:get_uid(), max_train = user:get_max_train_count()}}
  elseif self.config_id == BuildingConst.BUILDING.CityHall then
    user.ac = Tool:max({user.ac, user.max_ac})
    push_msg = {users = {{uid = user:get_uid(), ac = user.ac}}}
    if self.level == UserConst.OPEN_GOLD_LEVEL_LIMIT then
      user.first_login_time = os.time()
      user:refresh_blackmarket()
      user:set_close_blackmarket_timer()
      push_msg = Tool:merge({push_msg, user:get_blackmarket_info()}, user:get_pits_info())
    end
  elseif self.config_id == BuildingConst.BUILDING.RallyPoint then
    push_msg = {
      users = {
        [1] = {
          uid = user:get_uid(),
          max_armies = user:get_max_march_armies_amount(),
        },
      }
    }
  end
  game_cmd:exc_server_cmd("server_info_mgr", "record_building", user:get_uid(), self.config_id, self.level)
  user:check_quests("serverfirst:"..self.config_id..":"..self.level..":"..user:get_uid())
  user:del_build_event(self.event_id)
  user:check_quests("upgradebuilding:"..self.config_id..":"..self.level..":"..user:get_building_count_by(self.config_id, self.level))
  user:check_quests("build:"..self.config_id..":"..user:get_building_count(self.config_id))
  user:check_system_mail_send("building:"..self.config_id..":"..self.level)
  push_msg = push_msg or {}
  push_msg.buildings = push_msg.buildings or {}
  table.insert(push_msg.buildings, self:get_info())
  push_msg = Tool:merge({push_msg, user:get_building_events_info()})
  -- local rewards = self:get_upgrade_rewards()
  -- if not Tool:is_blank(rewards) then
  --   user:add_items(self:get_upgrade_rewards())
  --   user:send_push(user:get_items_info())        
  -- end
  local res_rewards = self:get_upgrade_res_rewards()
  if not Tool:is_blank(res_rewards) then
    user:add_resources(res_rewards)
    push_msg = Tool:merge({push_msg, user:get_resources_info()})
  end
  user:send_event_info({type = EventConst.BUILDING_EVENT_TYPE, config_id = self.config_id, level = self.level, items = self:get_upgrade_rewards_info()})
  local tguide = user:check_trigger_guide("build:"..self.config_id..":"..self.level)
  if tguide then
    push_msg = Tool:merge({push_msg, tguide})
  end
  user:check_func()
  user:check_quests()
  user:send_push(push_msg)
  user:save(true)
end

function M:get_upgrade_rewards(  )
  return ConfigBuildingDetail:get_rewards(self:get_detail())
end
function M:get_upgrade_res_rewards( )
  return ConfigBuildingDetail:get_res_rewards(self:get_detail())
end

function M:get_upgrade_rewards_info( )
  return Tool:map(self:get_upgrade_rewards(), function ( r )
    return {
      uid = r.item_id, 
      amount = r.amount
    }
  end)
end

function M:is_city_hall(  )
  return self.config_id == BuildingConst.BUILDING.CityHall
end

function M:is_city_Wall(  )
  return self.config_id == BuildingConst.BUILDING.Wall
end

function M:set_idle( )
  self.status = BuildingConst.BUILDING_STATUS.IDLE
end
function M:is_idle(  )
  return self.status == BuildingConst.BUILDING_STATUS.IDLE
end

function M:get_next_level_detail()
  return ConfigBuildingDetail:find_by_building_and_level(self.config_id, self.level + 1)
end

function M:get_detail(  )
  return ConfigBuildingDetail:find_by_building_and_level(self.config_id, self.level)
end

function M:is_in_working_status()
  return self.status == BuildingConst.BUILDING_STATUS.WORK
end

function M:can_train_army(amount)
  -- now we only limit the tower
  if not self:is_city_Wall() then
    return true
  end

  local detail = self:get_detail()
  local max_count_limit = detail.max_tower + self:get_user():get_MaxDefenseUnit_effect()
  local can_train_amount = self:get_max_train()
  local cur_tower =  self:get_user():get_all_tower_count() 

  if cur_tower + amount > max_count_limit then
      return false
  end

  if amount > can_train_amount then
      return false
  end

  return true
end

function M:get_next_level_resources(  )
  return ConfigBuildingDetail:get_resources(self:get_next_level_detail())
end

function M:set_user( user )
  self.__user = user
end

function M:get_user(  )
  return self.__user
end

function M:get_help(  )
  return self:get_detail().help
end

function M:get_injured( )
  return self:get_detail().injured
end

function M:get_cure_speed(  )
  return self:get_detail().cure_speed
end

function M:can_upgrade(  )
  if self:is_max_level() then
    return false
  end  
  return true
end

function M:can_free( )
  return self:is_building() and ((self.finish_time - os.time()) <= self:get_user():get_b_free_time())
end

function M:is_building(  )
  return self.status == BuildingConst.BUILDING_STATUS.BUILDING
end

function M:get_max_train( )
  if self:get_detail() then
    if self:is_city_Wall() then
      return tonumber(self:get_detail().max_tower + self:get_user():get_MaxDefenseUnit_effect())
    else
      return tonumber(self:get_detail().max_training + self:get_user():get_TrainingVolume_effect())
    end
  else
    return 0
  end
end

function M:get_speed(  )
  if self.speed.finish_time > os.time() then
    return self.speed.num
  else
    return 0
  end        
end
function M:get_food_income(  )
  if self:get_detail() then
    return math.floor(self:get_food_extra() * tonumber(self:get_detail().food_income))
  else
    return 0
  end    
end

function M:get_food_extra(  )
  return (1 + (self:get_user():get_AllProduction_effect() + self:get_user():get_FoodProduction_effect() + self:get_user():get_ExtraResource_effect() + self:get_speed())/100)
end

function M:get_food_capacity( )
  if self:get_detail() then
    return math.floor(tonumber(self:get_detail().food_capacity) * self:get_food_extra())
  else
    return 0
  end  
end

function M:get_wood_extra(  )
  return (1 + (self:get_user():get_AllProduction_effect() + self:get_user():get_WoodProduction_effect() + self:get_user():get_ExtraResource_effect() + self:get_speed())/100)
end

function M:get_wood_income(  )
  if self:get_detail() then
    return math.floor(self:get_wood_extra() * tonumber(self:get_detail().wood_income))
  else
    return 0
  end    
end

function M:get_wood_capacity( )
  if self:get_detail() then
    return math.floor(tonumber(self:get_detail().wood_capacity) * self:get_wood_extra())
  else
    return 0
  end    
end

function M:get_stone_extra(  )
  return (1 + (self:get_user():get_AllProduction_effect() + self:get_user():get_StoneProduction_effect() + self:get_user():get_ExtraResource_effect() + self:get_speed())/100)
end

function M:get_stone_income(  )
  if self:get_detail() then
    return math.floor(self:get_stone_extra() * tonumber(self:get_detail().stone_income))
  else
    return 0
  end
end

function M:get_stone_capacity( )
  if self:get_detail() then
    return math.floor(tonumber(self:get_detail().stone_capacity) * self:get_stone_extra())
  else
    return 0
  end    
end

function M:get_ore_extra(  )
  return (1 + (self:get_user():get_AllProduction_effect() + self:get_user():get_OreProduction_effect() + self:get_user():get_ExtraResource_effect() + self:get_speed())/100)
end

function M:get_ore_income(  )
  if self:get_detail() then
    return math.floor(self:get_ore_extra() * tonumber(self:get_detail().ore_income))
  else
    return 0
  end    
end

function M:get_ore_capacity( )
  if self:get_detail() then
    return math.floor(tonumber(self:get_detail().ore_capacity) * self:get_ore_extra())
  else
    return 0
  end
end

function M:addons(  )
  local ons = BuildingAddOns[self.config_id]
  if ons then 
    Tool:merge({self, ons}) 
  end
end

function M:get_res( trigger_skill )
  if not self.get_res_type then return {} end
  local rt = self:get_res_type(self)
  local amount = Tool:min({math.floor(((os.time() - self.updated_time) / 3600 * rt.income)), rt.capacity}) 
  amount = math.floor(amount * (1 + self:get_user():get_ExtraResource_effect()/100))
  if trigger_skill then
    local extra = self:get_user():get_ResourceErupt_effect({event = UserConst.COLLECT_RES_EVENT})
    if extra > 0 then
      local res = self:get_user():get_hour_res(extra)
      self:get_user():add_resources(res)
    end
  end
  local resource = {}
  resource[rt.res] = amount + self.amount
  self.updated_time = os.time()
  return resource
end

function M:get_score(  )
  if self:get_detail() then
    return self:get_detail().score
  else
    return 0
  end      
end

function M:get_army_resources(  )
  local conf = ConfigMonster:find_by_id(self.armies[1]._id)
  return ConfigMonster:get_resources(conf, self.armies[1].amount)
end

function M:check_require(  )
  if not self:get_detail() then return true end
  for i,v in ipairs(ConfigBuildingDetail:get_unlock_conditions(self:get_next_level_detail())) do
    local level = self:get_user():get_building_highest_level(v.building_id)
    if level < tonumber(v.level) then
      return false
    end  
  end 
  return true
end

function M:complete_train(  )
  local user = self:get_user()
  user:building_remove_help(self._id)
  self.status = BuildingConst.BUILDING_STATUS.COLLECT
  self.can_help = false
  if self.armies[1] then
    user:send_push({buildings = {self:get_info()}})
    user:send_event_info({type = EventConst.TRAIN_EVENT_TYPE, config_id = self.armies[1]._id, amount = self.armies[1].amount})
  end
  if self.event_id then
    user:del_build_event(self.event_id)
  end
  game_cmd:exc_event_cmd("del", self.event_id)
  self.event_id = ''  
end

function M:complete_cure( )
  local user = self:get_user()
  user:building_remove_help(self._id)
  self.status = BuildingConst.BUILDING_STATUS.COLLECT
  self.can_help = false
  if self.armies[1] then
    user:send_push({buildings = {self:get_info()}})
    user:send_event_info({type = EventConst.CURE_EVENT_TYPE, amount = Tool:sum(self.armies, function ( a )
      user.c_units = user.c_units + a.amount
      return a.amount
    end)})
  end
  if self.event_id then
    user:del_build_event(self.event_id)
  end
  game_cmd:exc_event_cmd("del", self.event_id)
  self.event_id = ''
end

function M:complete_research(  )
  if self.work == 0 then return {} end
  local user = self:get_user()
  user:building_remove_help(self._id)
  self.can_help = false
  game_cmd:exc_event_cmd("del", self.event_id)
  user:upgrade_research(self.work)
  local research_level = user:get_research_level(self.work)
  local qusest_list = {}
  table.insert(qusest_list, "research:"..self.work..":"..research_level)
  table.insert(qusest_list, "totalresearch:1")
  user:check_quests(qusest_list)
  local research_info = {researches = {{uid = self.work, level = research_level}}}
  user:send_push(research_info)
  user:send_event_info({type = EventConst.RESEARCH_EVENT_TYPE, config_id = self.work, level = research_level})
  self.status = BuildingConst.BUILDING_STATUS.IDLE
  self.work = 0
  self.event_id = ''
  user:send_push({buildings = {self:get_info()}})
  return research_info
end

function M:speed_up_upgrade( time )
  local user = self:get_user()
  self.finish_time = self.finish_time - time
  local e = game_cmd:exc_event_cmd("speed_time", self.event_id, time)
  self.finish_time = e and e.finish_time or os.time()
  user:send_push(Tool:merge({
    {buildings = {{
        uid = self:get_uid(),
        status = self.status,
        level = self.level,
        specs = self:get_spec_info(),
        finish_time = self.finish_time
      }
    }},
    user:get_building_events_info()
  }))
end

function M:speed_up_train( time )
  local user = self:get_user()
  local e = game_cmd:exc_event_cmd("speed_time", self.event_id, time)
  self.finish_time = e and e.finish_time or os.time()
  user:send_push({buildings = {self:get_info()}})
end

function M:speed_up_research( time )
  local user = self:get_user()
  local e = game_cmd:exc_event_cmd("speed_time", self.event_id, time)
  if not e then return end
  self.finish_time = e and e.finish_time or os.time()
  if not e.finished then
    user:send_push({buildings = {self:get_info()}})
  end
end

function M:speed_up_cure( time )
  local user = self:get_user()
  local e = game_cmd:exc_event_cmd("speed_time", self.event_id, time)
  self.finish_time = e and e.finish_time or os.time()
  if e and not e.finished then -- e可能是nil
    user:send_push({buildings = {self:get_info()}})
  end
end

function M:speed_up( time )
  if self.status == BuildingConst.BUILDING_STATUS.BUILDING then
    self:speed_up_upgrade(time)
  elseif self.status == BuildingConst.BUILDING_STATUS.WORK then
    self:speed_up_train(time)
  elseif self.status == BuildingConst.BUILDING_STATUS.RESEARCH then
    self:speed_up_research(time)
  elseif self.status == BuildingConst.BUILDING_STATUS.CURE then
    self:speed_up_cure(time)
  end
end

function M:help_speed_up(  )
  self:speed_up(self:get_user():get_uhelp_time())
end

function M:get_finish_time(  )
  return Tool:max({os.time() + 
      math.ceil((self:get_next_level_detail().time * 
      (1 - self:get_user():get_ConstructionSpeed_effect()/100))) -
      self:get_user():get_ReduceBuildTime_effect({event = UserConst.UP_BUILDING_EVENT}), 
      os.time()
    })
end

function M:get_convert_gems( )
  -- 如果改了通知客户端同步
  return math.ceil(self.level*self.level*1.9+self.level*1.3)
end

function M:get_survive_info(  )
  return Tool:map(self.survive, function ( s )
    return {
      uid = s._id,
      amount = s.amount
    }
  end)
end

function M:clear_survice(  )
  for k,v in pairs(self.survive) do
    v.amount = 0
  end
end

function M:get_buff_gems(  )
  return self:get_config():get_buff_gems(self.level)
end

function M:collect_res( hero_skill )
  local res = self:get_res(hero_skill)
  self:get_user():add_resources(res)
  self.amount = 0
  return res
end

BuildingAddOns = {}

BuildingAddOns[BuildingConst.BUILDING.Quarry] = {
  get_res_type = function ( self )
    return {
      income = self:get_stone_income(),
      capacity = self:get_stone_capacity(),
      res = 'stone'
    }
  end,  
  get_spec_info = function ( self )
    return {
      income = self:get_stone_income(),
      capacity = self:get_stone_capacity(),
      updated_time = self.updated_time,
      amount = self.amount
    }
  end
}
BuildingAddOns[BuildingConst.BUILDING.Sawmill] = {
  get_res_type = function ( self )
    return {
      income = self:get_wood_income(),
      capacity = self:get_wood_capacity(),
      res = 'wood'
    }
  end,  
  get_spec_info = function ( self )
    return {
      income = self:get_wood_income(),
      capacity = self:get_wood_capacity(),
      updated_time = self.updated_time,
      amount = self.amount
    }
  end
}

BuildingAddOns[BuildingConst.BUILDING.Smelter] = {
  get_res_type = function ( self )
    return {
      income = self:get_ore_income(),
      capacity = self:get_ore_capacity(),
      res = 'ore'
    }
  end,  
  get_spec_info = function ( self )
    return {
      income = self:get_ore_income(),
      capacity = self:get_ore_capacity(),
      updated_time = self.updated_time,
      amount = self.amount
    }
  end
}

BuildingAddOns[BuildingConst.BUILDING.Farm] = {
  get_res_type = function ( self )
    return {
      income = self:get_food_income(),
      capacity = self:get_food_capacity(),
      res = 'food'
    }
  end,  
  get_spec_info = function ( self )
    return {
      income = self:get_food_income(),
      capacity = self:get_food_capacity(),
      updated_time = self.updated_time,
      amount = self.amount
    }
  end
}

BuildingAddOns[BuildingConst.BUILDING.House] = {
  get_spec_info = function ( self )
    return {
      arms = self:get_config():get_arms_info(self:get_user():get_opened_arms())
    }
  end
}

BuildingAddOns[BuildingConst.BUILDING.Factory] = {
  get_spec_info = function ( self )
    return {
      arms = self:get_config():get_arms_info(self:get_user():get_opened_arms())
    }
  end
}

BuildingAddOns[BuildingConst.BUILDING.Wall] = {
  get_spec_info = function ( self )
    return {
      arms = self:get_config():get_arms_info(self:get_user():get_opened_arms())
    }
  end
}

return M

