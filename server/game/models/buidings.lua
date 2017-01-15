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