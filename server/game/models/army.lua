
local M = {}

local DEFAULT = {
  user_id = '',
  config_id = 0,
  amount = 0,
  total = 0,
  injured = 0,
  lost = 0,
  status = 0,
  loses = 0,
  kills = 0,
  damage = 10
}

Army = M

function M:new( o )
  o = o or {}
  o.total = o.amount
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:factory( params )
  Tool:add_merge({params, DEFAULT})
  return self:new(params)
end

function M:get_config(  )
  return ConfigMonster:find_by_id(self.config_id)
end

function M:get_hp( )
  return self:get_config().life + self:get_config().armor
end

function M:get_power (  )
  return self:get_config().attack_max * self.amount
end

function M:get_might(  )
  return math.floor(self:get_config().might * self.amount)
end

function M:get_load_power()
  return self:get_config().load * self.amount
end

function M:get_info(  )
  return {
    uid = self.config_id, 
    total = self.total, 
    amount = self.amount, 
    kills = self.kills, 
    injured = self.injured,
    lost = self.lost,
    survive = self.amount,
    might = self:get_might(),
    damage = self.damage
  }
end

return M

