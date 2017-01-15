local M = ConfigBase:new()
local Tool = require 'tool'

ConfigLeagueGiftRule = M

M:set_origin(config_league_gift_rules)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:find_by_purchase_id( purchase_id )
  return Tool:find(self:sall(), function ( r )
    return r.purchase_id == purchase_id
  end)
end

M:load()

return M
