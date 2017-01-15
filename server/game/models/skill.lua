local M = {}

local DEFAULT = {
  _id = 0,
  config_id = 0, -- 建筑的配置ID
  level = 0, -- 初始等级
}

Skill = M

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:factory( params, user )
  Tool:add_merge({params, DEFAULT})
  if not params._id or params._id == 0 then
    user.keys.skill = user.keys.skill + 1
    params._id = user.keys.skill
  end
  return self:new(params)
end

function M:factory_skynet( params )
  Tool:add_merge({params, DEFAULT})
  return self:new(params)
end

function M:get_config(  )
  return ConfigSkill:find_by_id(self.config_id)
end

function M:set_hero( hero )
  self.__hero = hero
end

function M:get_hero(  )
  return self.__hero
end

function M:get_uid()
  return self.config_id
end

function M:get_info( )
  return {
    uid = self:get_uid(),
    config_id = self.config_id,
    level = self.level,
    cur_t = self:get_current_skill_text(),
    next_t = self:get_next_skill_text()
  }
end

function M:get_talent_info(  )
  return {
    uid = self:get_uid(),
    config_id = self.config_id,
    level = self.level,
    cur_t = self:get_current_skill_text(),
    next_t = self:get_next_skill_text()
  }
end

function M:get_talent_buffs_text( )
  local text = {}  
  table.insert(text, self:get_chance())
  Tool:map(self:get_config():get_buffs(), function ( b )
    table.insert(text, b.func(self.level))
  end)
  return text
end

function M:get_next_talent_buffs_text(  )
  if self:is_max_level() then 
    return self:get_talent_buffs_text()
  else    
    local text = {}
    table.insert(text, self:get_next_chance())
    Tool:map(self:get_config():get_buffs(), function ( b )
      table.insert(text, b.func(self.level + 1)) 
    end)
    return text
  end
end

function M:get_effects(  )
  return Tool:map(self:get_config():get_buffs(), function ( b )
    b.num = b.func(self.level)
    return b
  end)   
end

function M:get_buffs_text(  )
  return Tool:map(self:get_config():get_buffs(), function ( b )
    return b.func(self.level)
  end) 
end

function M:get_next_buffs_text(  )
  if self:is_max_level() then 
    return self:get_buffs_text()
  else    
    return Tool:map(self:get_config():get_buffs(), function ( b )
      return b.func(self.level + 1)
    end)
  end    
end

function M:get_cur_buffs()
  local buff = self:get_config():get_buffs()
  for k, v in pairs(buff) do
    v.effectRate = v.func(self.level)
  end
  return buff
end

function M:get_hero_pos_buffs(  )
  local buff = self:get_config():get_hero_pos_buffs()
  local rates = {}
  for k, v in pairs(buff) do
    v.num = v.func(self.level)
    rates[k] = v.rate
  end
  return buff[Tool:lottery(rates)]
end

function M:get_chance(  )
  return self:get_config():get_change_func()(self.level)
end

function M:get_next_chance(  )
  return self:get_config():get_change_func()(self.level + 1)
end

function M:get_full_battle_skill_info()
  local info = self:get_config():get_battle_info()
  info.chance = info.func(self.level)
  info.buff = self:get_cur_buffs()
  return info
end

function M:upgrade(  )
  if self.level == 0 then return false end
  if self:is_max_level() then return false end
  self:get_hero().sp = self:get_hero().sp - 1
  self.level = self.level + 1
  return true
end

function M:is_max_level()
  return self.level >= self:get_config().max_level
end

function M:get_current_skill_text()
  return Tool:map(self:get_config():get_skill_value(), function ( b )
    return b.func(self.level)
  end) 
end
function M:get_next_skill_text()
  if self:is_max_level() then 
    return self:get_current_skill_text()
  else    
    return Tool:map(self:get_config():get_skill_value(), function ( b )
      return b.func(self.level + 1)
    end)
  end  
end

return M