local M = ConfigBase:new()

ConfigGambling = M

M:set_origin(config_gamblings)

function M:get_coins(  )
  if self.__coins then return self.__coins end
  self.__coins = Tool:map(Tool:split(self.coins_consume, ','), function ( coin )
    return tonumber(coin)
  end) 
  return self.__coins
end

function M:get_coins_by_times( times )
  return self:get_coins()[times]
end

function M:get_person(  )
  if self.__person then return self.__person end
  self.__person = self:sall()[1]
  return self.__person
end

function M:get_union(  )
  if self.__union then return self.__union end
  self.__union = self:sall()[2]
  return self.__union
end

M:load()

return M
