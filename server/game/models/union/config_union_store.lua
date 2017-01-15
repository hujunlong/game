
require "config_alliacne_shop"

local M = ConfigBase:new()

ConfigUnionStore = M

M:set_origin(config_alliacne_shop)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:load(  )
  self.__records = {}
  for k, v in ipairs(self:get_origin()) do
    local config = self:new(v)
    config:init_condition()
    self.__records[v._id] = config
    table.insert(self.__srecords, self.__records[v._id])
  end
end

function M:init_condition()
  if type(self.goods_currency) ~= 'string' then return end

  local strs = Tool:split(self.goods_currency, ':')
  if strs[1] == '1' then
    self.condition = self.condition or {}
    self.condition.members = {
      num = tonumber(strs[2]),
    }
  elseif strs[1] == '2' then
    self.condition = self.condition or {}
    self.condition.members = {
      level = tonumber(strs[2]),
      num = tonumber(strs[3]),
    }
  elseif strs[1] == '3' then
    self.condition = self.condition or {}
    self.condition.contribution = tonumber(strs[2])
  end
end

function M:can_replenish_stock(union)
  if self.condition == nil then return true end

  if self.condition.members
      and Union:get_member_count(union, self.condition.members.level) < self.condition.members.num then
    return false
  end

  if self.condition.contribution and union.total_contribution < self.condition.contribution then
    return false
  end

  return true
end

function M:get_user_price()
  return self.contribution
end

function M:get_union_price()
  return self.price
end

M:load()

return M
