local M = {}

local DEFAULT = {
  _id = 0,
  config_id = 0, -- 建筑的配置ID
  level = 0, -- 初始等级
  valid = false,
  exp = 0
}

Equipment = M

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:factory( params, user )
  Tool:add_merge({params, DEFAULT})
  if not params._id or params._id == 0 then
    user.keys.equipment = user.keys.equipment + 1
    params._id = user.keys.equipment
  end  
  local e = self:new(params)
  e:set_user(user)
  return e
end

function M:get_user  () 
  return self.__user
end  

function M:set_user  (user) 
  self.__user = user
end  