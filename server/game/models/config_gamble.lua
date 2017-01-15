local M = ConfigGamble = Class('ConfigGamble', ConfigBase:new())

M:set_origin(config_gambles)

function M:get_coins(  )
  if self.__coins then return self.__coins end
  self.__coins = Tool:split(self.coins_consume, ',')
  return self.__coins
end

M:load()

return M
