
local M = {
  OPEN = 1,          -- 任务为可领取状态(未接受)
  DRAW = 2,          -- 任务为进行状态（已经领取，开始做任务）
  REWARD = 3,        -- 任务为领奖状态（任务条件达成，可以领奖）
  COMPLETE = 4      -- 任务为完成状态并关闭（已经领奖，任务关闭）
}

local DEFAULT = {
  _id = 0,
  config_id = 0,
  cur = 0, -- #任务当前进度
  max = 0, -- 完成任务的目标值
  status = 0, 
  deadline = 0
}

Quest = M

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:factory( params, user )
  Tool:add_merge({params, DEFAULT})
  if not params._id or params._id == 0 then
    user.keys.quest = user.keys.quest + 1
    params._id = user.keys.quest
  end
  local quest = self:new(params)
  quest:set_user(user)
  return quest
end

function M:get_uid  () 
  return self._id
end  

function M:get_info  ()
  return {
    uid = self:get_uid(),
    config_id = self.config_id,
    cur = math.floor(self.cur),
    max = self.max,
    deadline = self.deadline,
    status = self.status,
    target = ConfigQuest:get_target(self:get_config()).building_id --self:get_config():get_target().building_id
  }
end  

function M:get_config  () 
  return ConfigQuest:find_by_id(self.config_id)
end  

function M:is_reward  () 
  if self.deadline ~= 0 then
    if self.deadline <= os.time() then
      self.status = Quest.REWARD
    else
      self.cur = 0
    end
  end
  return self.status == Quest.REWARD
end

function M:is_draw  () 
  return self.status == Quest.DRAW
end
function M:is_complte  () 
  return self.status == Quest.COMPLETE
end

function M:is_idle  ()
  return self.status == 0
end

function M:set_reward(  )
  if self.status == Quest.COMPLETE 
    or self.status == Quest.REWARD
    then 
    return 
  end
  -- local front_quest_id = self:get_config().front_quest
  -- if not self:get_user():has_finish_quest(front_quest_id) then return end
  if self.status ~= Quest.REWARD then
    self.max = self.cur
    self.status = Quest.REWARD
    if not self:get_user():find_quest_by_config_id(self.config_id) and not self:get_user():has_finish_quest(self.config_id) then
      table.insert(self:get_user().quests, self)
      self:get_user():send_push({quests = {self:get_info()}})
    end
    self:get_user():check_func(self.config_id)
    self:get_user():receive_main_quest()
    if self.config_id >= 3006 and self.config_id <= 3015 then
      self:get_user():check_send_rating_pop()
    end
  end
end

function M:get_user  () 
  return self.__user
end  

function M:set_user  (user) 
  self.__user = user
end  

function M:complete  () 
  if not self:is_reward() or self:is_complte() then return false end
  local user = self:get_user()
  local q_config = self:get_config()
  user:add_resources(ConfigQuest:get_reward(q_config))
  user:add_armies(ConfigQuest:get_battle_unit(q_config))
  user:add_items(ConfigQuest:get_items(q_config))
  user:send_push(user:get_items_info())
  if q_config.title ~= 0 then
    user:add_title(q_config.title)
    user:send_push({users = {{uid = user:get_uid(), titles = user.titles}}})
  end
  user:add_finish_quest(self.config_id)
  if q_config.contribution > 0 then
    game_cmd.Union.add_contri(user.union_id, user._id, q_config.contribution)
  end
  self.status = self.COMPLETE
  -- 开启后置任务
  local quests = {} 
  for k,cq in pairs(ConfigQuest.__config) do
    if cq.front_quest == self.config_id and not user:has_finish_quest(cq._id) and not user:find_quest_by_config_id(cq._id) then
      table.insert(quests, user:receive_quest(cq._id))
    end
  end
  if #quests > 0 then
    user:send_push({quests = Tool:map(quests, function ( r )
      return r:get_info()
    end)})
  end
  if self.type == QuestConst.ACHIVEMENT then
    self:check_target("completeachievement:1")
  end
  self:remove()
  return true
end

function M:remove(  )
  Tool:remove(self:get_user().quests, self) 
end

function M:check_target ( target )
  if self:is_reward() or self:is_complte() then return false end
  if self:get_config().target == target then
    self.cur = self.max
    self:set_reward()
  else
    local user = self:get_user()
    -- self:get_config():check(self, user, target)

    ConfigQuest:check(self:get_config(), self, user, target)
  end
  return true
end

function M:get_pos_info(  )
  local tile = nil
  local cur_user = self:get_user()
  local user_pos = {x = cur_user.x, y = cur_user.y, id = cur_user._id}
  local guide = ConfigQuest:get_guide(self:get_config())[1]
  if guide == QuestConst.GUIDE.FIND_MINE then
    tile = game_cmd:exc_wild_cmd("wild", "get_nearest_mine", user_pos, self:get_config().guide_2)
  elseif guide == QuestConst.GUIDE.FIND_LEVEL_MONSTER then  
    tile = game_cmd:exc_wild_cmd("wild", "get_nearest_monster", user_pos, nil, self:get_config().guide_2)
  elseif guide == QuestConst.GUIDE.FIND_MATCH_MONSTER then
    tile = game_cmd:exc_wild_cmd("wild", "get_nearest_monster", user_pos, nil, nil, cur_user.max_monster_level)
  elseif guide == QuestConst.GUIDE.FIND_NEAREST_USER then
    tile = game_cmd:exc_wild_cmd("wild", "get_nearest_city", user_pos)
  end
  if tile then
    return {pos = {x = tile.x, y = tile.y}}
  else
    return {pos = {x = 1, y = 1}}
  end    
end

function M:is_union(  )
  return ConfigQuest:is_union(self:get_config())
end

function M:reset_deadline(  )
  self.deadline = self:get_config().time + os.time()
end

return M