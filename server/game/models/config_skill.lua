local M = ConfigBase:new()

ConfigSkill = M

M:set_origin(config_skills)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

--效果ID,效果数值, 是否可持续, 开始轮次间隔,持续轮次,可叠加层次
function M:get_buffs(  )
  if self.__buffs then return self.__buffs end
  self.__buffs = {}
  for k,str in pairs(Tool:split(self.buff, ',')) do
    local t = Tool:split(str, ':')
    local o = {}
    o.effect_id = t[1]
    o.func = loadstring("return function (n) return "..t[2].." ; end")()
    o.can_active_num = tonumber(t[3])
    o.start_round_step = tonumber(t[4])
    o.continue_round = tonumber(t[5])
    o.overlay_total = tonumber(t[6])
    table.insert(self.__buffs, o) 
  end
  return self.__buffs
end

function M:get_battle_info()
  if self.__skill_info then return self.__skill_info end
  self.__skill_info = {}
  self.__skill_info._id = self._id
  self.__skill_info.func = loadstring("return function (n) return "..self.chance.." ; end")()
  self.__skill_info.order = self.order
  self.__skill_info.effect_type = self.effect_type
  self.__skill_info.proc_timing = self.proc_timing
  self.__skill_info.trigger_cd = self.trigger_cd
  self.__skill_info.target_type = self.target
  self.__skill_info.whether_damage = self.whether_damage
  self.__skill_info.effect_target = self.effect_target

  return self.__skill_info
end

function M:get_hero_pos_buffs(  )
  if self.__hero_pos_buffs then return self.__hero_pos_buffs end
  self.__hero_pos_buffs = {}
  for k,str in pairs(Tool:split(self.buff, ',')) do
    local t = Tool:split(str, ':')
    local o = {}
    o.effect_id = tonumber(t[1])
    o.func = loadstring("return function (n) return "..t[2].." ; end")()
    o.rate = tonumber(t[3])
    o.item_id = tonumber(t[4] or 0)
    table.insert(self.__hero_pos_buffs, o)
  end
  return self.__hero_pos_buffs
end

function M:get_change_func(  )
  if self.__chance_func then return self.__chance_func end
  self.__chance_func = loadstring("return function (n) return "..self.chance.." ; end")()
  return self.__chance_func
end

function M:get_skill_value(  )
  if self.__skill_values then return self.__skill_values end
  self.__skill_values = {}
  local t = Tool:split(self.skill_value, ',')
  for k, v in pairs(t) do
    local o = {}
    o.func = loadstring("return function (n) return "..v.." ; end")()
    table.insert(self.__skill_values, o) 
  end

  return self.__skill_values
end

M:load()

return M
