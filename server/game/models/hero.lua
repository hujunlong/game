local HeroConst = require 'hero_const'

local M = {
}

local DEFAULT = {
  config_id = 0,
  level = 1,
  star = 0, 
  quality = 1, 
  sub_quality = 0,
  exp = 0, 
  equipments = {},
  skills = {},
  talent =  {},
  effects = {}, 
  sp = 0,
  pos = 0,
  status = 0,
  position = {}, -- {x=0, y=0}
  trigger_times = 0,
  skill_cd = 0,
  work = HeroConst.Work.IDLE,
  is_defender = false,
  equip_bag = {},
}

Hero = M

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:factory( params, user, is_old )
  Tool:add_merge({params, DEFAULT})
  if not params._id or params._id == 0 then
    user.keys.hero = user.keys.hero + 1
    params._id = user.keys.hero
  end    

  if not params.position.x then
    params.position.x = user.x
    params.position.y = user.y
  end

  local hero = self:new(params)
  hero.is_old = is_old
  hero:set_user(user)
  if not hero.is_old then
    hero.star = hero:get_config().star
  end    
  hero:refresh_equipments()
  hero:init_skills()
  hero:init_talent()
 
  return hero
end

function M:factory_skynet( params )
  Tool:add_merge({params, DEFAULT})
  local hero = self:new(params)
  return hero
end

function M:get_uid(  )
  return self.config_id
end

function M:get_info(  )
  return {
    uid = self:get_uid(),
    config_id = self.config_id,
    star = self.star,
    quality = self.quality,
    level = self.level,
    exp = self.exp,
    nexp = self:get_next_level_exp(),
    pos = self.pos,
    skills = self:get_skills_info(),
    sp = self.sp,
    equipments = self:get_equipments_info(),
    status = self.status,
    talent = self:get_config().talent,
    talent_effects = self.talent[1]:get_talent_info(),
    effects = self:get_effects(),
    position = self.position,
    work = self.work,
    is_defender = self.is_defender,
    equip_bag = self:get_equip_bag_info(),
  }
end

function M:add_effects( t1, t2 )
  local result = {}
  for k,v in pairs(t1) do
    result[k] = Tool:clone(v)
    if t2[k] then
      result[k].num = result[k].num + t2[k].num
    end  
  end
  for k,v in pairs(t2) do
    if not t1[k] then
      result[k] = Tool:clone(v)
    end
  end
  return result
end

function M:get_effects( )
  local effects = Tool:clone(self.effects)
  for i,e in pairs(self.equipments) do
    if e.valid then
      effects = self:add_effects(effects, e:get_config():get_effects_t())
    end
  end
  return effects
end

function M:get_skills_info(  )
  return Tool:map(self.skills, function ( skill, index )
    local i = skill:get_info()
    i.index = index
    return i
  end)
end

function M:get_skills_effects(  )
  local effects = {}
  Tool:map(self.skills, function ( skill, index )
    for k,v in pairs(skill:get_effects()) do
      table.insert(effects, v)
    end
  end)
  return effects
end

function M:get_equipments_info(  )
  return Tool:map(self.equipments, function ( e, index )
    local i = e:get_info()
    i.uid = index
    return i
  end)
end

function M:get_config(  )
  return ConfigHero:find_by_id(self.config_id)
end

function M:get_user(  )
  return self.__user  
end

function M:set_user( user )
  rawset(self, '__user', user)
  -- self.__user = user
end

function M:set_position(x, y)
  self.position.x = x
  self.position.y = y
end

function M:get_cur_max_level(  )
  local hero_hall = self:get_user():find_building_by_config_id(BuildingConst.BUILDING.HeroHall)
  if hero_hall and hero_hall:get_detail() then
    return hero_hall:get_detail().hero_level
  else
    return BuildingConst.HERO_INIT_MAX_LEVEL
  end
end

function M:_add_exp( exp )
  if exp <= 0 then return false end
  if self:is_max_level() then return false end
  local need = self:get_next_level_exp() - self.exp
  local more = exp - need
  if more >= 0 then
    self.level = self.level + 1
    self.exp = 0
    self.sp = self.sp + self:get_config().sp
    self:get_user():check_quests("herolevelup:"..self.level)
    self:get_user():send_push({heroes = {self:get_info()}})
    self:_add_exp(more)
  else
    self.exp = self.exp + exp
  end
  return self.exp    
end

function M:get_cur_exp_percent()
  local nexp = self:get_next_level_exp()
  local percent = math.floor(self.exp/nexp * 100)
  return percent
end

function M:add_exp( exp )
  local exp = self:_add_exp(exp)
  self:get_user():send_push({heroes = {uid = self:get_uid(), exp = self.exp}})
  return exp
end

function M:is_max_level( )
  return self:get_cur_max_level() <= self.level
end

function M:get_next_level_exp( )
  return self:get_next_config_level().exp
end

function M:get_next_config_level(  )
  return ConfigHeroLevel:find_by_level(self.level + 1) or ConfigHeroLevel:find_by_level(self.level)
end

function M:get_next_config_star(  )
  return ConfigHeroStar:find_by_star(self.star + 1) or ConfigHeroStar:find_by_star(self.star)
end

function M:is_max_star(  )
  return self:get_config().max_star <= self.star
end

function M:upgrade_star(  )
  if self:is_max_star() then return false end
  if not self:get_user():use_item(self:get_config().soul, self:get_next_config_star().need_souls) then
    return false
  end
  self.star = self.star + 1
  if self.star > 1 then
    self.sp = self.sp + self:get_config().star_reward
  end
  self.talent[1].level = self.talent[1].level + 1
  self:get_user():check_quests("herostart:"..self:get_user():get_star_hero_count(self.star)..":"..self.star)
  return true  
end

function M:is_max_quality  () 
  return self.quality >= self:get_config().max_quality
end  

function M:upgrade_quality  () 
  if self:is_max_quality() then return false end
  if not self:has_series_equipments() then return false end
  self.quality = self.quality + 1
  self:eat_equipments()
  self:unlock_skills()
  self:get_user():check_quests("herorankup:"..self:get_user():get_quality_hero_count(self.quality)..":"..self.quality)
  return true
end  

function M:refresh_equipments  () 
  if self.is_old then
    self.equipments = Tool:map(self.equipments, function ( data )
      return Equipment:factory(data, self:get_user())
    end)
  else    
    self:reset_equipments()
  end
  return self.equipments
end

function M:reset_equipments(  )
  for k,v in pairs(self.equipments) do
    local id = tostring(v.config_id)
    self.equip_bag[id] = self.equip_bag[id] or 0
    self.equip_bag[id] = self.equip_bag[id] + 1
  end
  self.equipments = Tool:map(self:get_config():get_equipments()[self.quality], function ( equipment_id )
    return Equipment:factory({config_id = equipment_id}, self:get_user())
  end) 
  return self.equipments
end

function M:get_equip_bag_info(  )
  local info = {}
  for id,amount in pairs(self.equip_bag) do
    table.insert(info, {uid = tonumber(id), amount = amount})
  end
  return info
end

function M:has_series_equipments  () 
  for i,e in ipairs(self.equipments) do
    if not e.valid then return false end
  end
  return true
end  

function M:get_equipment_count(  )
  local count = 0
  for i,e in ipairs(self.equipments) do
    if e.valid then count = count + 1 end
  end
  return count
end

function M:eat_equipments  () 
  for i,e in ipairs(self.equipments) do
    self.effects = self:add_effects(self.effects, e:get_config():get_effects_t())
  end
  self:reset_equipments()
end

function M:wear_equipment  (equipment_id) 
  local equipment = Tool:find(self.equipments, function ( e )
    return e.config_id == equipment_id and not e.valid
  end)
  if not equipment then return false end
  if self.level < equipment:get_config().level_limit then return false end
  equipment.valid = true
  return true
end  

function M:find_equipment_by_config_id  (config_id) 
  return Tool:find(self.equipments, function ( e )
    return e.config_id == config_id and e.valid
  end)
end  

function M:init_skills  () 
  if self.is_old then
    self.skills = Tool:map(self.skills, function ( data )
      return Skill:factory(data, self:get_user())
    end)
  else
    self.skills = Tool:map(self:get_config():get_skill_ids(), function ( skill_id, index )
      if index == 1 then
        return Skill:factory({config_id = skill_id, level = 1}, self:get_user())
      else
        return Skill:factory({config_id = skill_id}, self:get_user())
      end
    end)
  end    
  self:unlock_skills()
end

function M:unlock_skills  () 
  local skill_id = self:get_config():get_skill_unlock()[self.quality]
  if not skill_id then return false end
  skill = self:find_skill_by_config_id(skill_id)
  if not skill then return false end
  if skill.level == 0 then
    skill.level = 1
  end
  return true
end  

function M:find_skill_by_config_id  (config_id) 
  return Tool:find(self.skills, function ( s )
    return s.config_id == config_id
  end)
end  

function M:init_talent  () 
  if self.is_old then
    self.talent = {Skill:factory(self.talent[1], self:get_user())}
  else
    self.talent = {Skill:factory({config_id = self:get_config().talent, level = 1}, self:get_user())}
  end
end  

function M:get_trigger_skill_info( effects )
  local skill_id = self.talent[1].config_id
  local info = {hero_skill_trigger = {config_id = self.config_id, skill_id = skill_id}}
  opts = opts or {}
  if skill_id == 31005 or skill_id == 31015 or skill_id == 31020 or skill_id == 31025 then
    info.hero_skill_trigger.type = 1
    info.hero_skill_trigger.effect_value = Tool:format_sec(self.talent[1]:get_talent_buffs_text()[2]) 
  elseif skill_id == 31010 then
    info.hero_skill_trigger.type = 1
    info.hero_skill_trigger.effect_value = tostring(self.talent[1]:get_talent_buffs_text()[2])
  elseif skill_id == 31030 then
    info.hero_skill_trigger.type = 2
    info.hero_skill_trigger.resources = {}
    local num = self.talent[1]:get_talent_buffs_text()[2]
    info.hero_skill_trigger.resources = self:get_user():get_hour_res(num)
  elseif effects['8038'] then
    self:get_user():add_item(effects.item_id, 1)
    info.hero_skill_trigger.type = 3
    info.hero_skill_trigger.item_id = effects.item_id
    info.hero_skill_trigger.item_num = 1
  end
  return info
end

return M