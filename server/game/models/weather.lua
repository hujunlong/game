require 'config_weather'
local timer = require "timer_proxy"
local skynet = require "skynet"

local M = {
  RAINY = 2,
  SUNNY = 1,
  ONE_DAY_SECONDS = 3600 * 24,
  TWO_WEEK_SECONDS = 3600 * 24 * 14,
}

function M:setserverInfo(serverinfo)
  self.m_serverinfo = serverinfo
end

function M:get_info( count )
  if self.is_debug == nil then
    self.is_debug = game_cmd:exc_server_cmd("server_info_mgr", "is_debug")
  end
  
  local info = {}
  for i,day in ipairs(self.m_serverinfo.days) do
    if day.t > os.time() - self.ONE_DAY_SECONDS then
      table.insert(info, {
        type = self.is_debug and self.RAINY or day.w,
        time = day.t,
      })
      if #info >= count then break end
    end
  end

  return {weather = info}
end

function M:refresh(  )
  Tool:delete(self.m_serverinfo.days, function ( day )
      return day.t < os.time() - self.ONE_DAY_SECONDS
    end, true)

  local last_day = Tool:last(self.m_serverinfo.days)
  local current_time = os.time()
  local today_start = current_time - current_time % self.ONE_DAY_SECONDS;
  while (not last_day or last_day.t < today_start + self.TWO_WEEK_SECONDS) do
    local rainy_days = math.random(config_weather[1].rain_min, config_weather[1].rain_max)
    local weather = {}
    for i = 1, (7 - rainy_days) do
      table.insert(weather, self.SUNNY)
    end

    for i = 1, rainy_days do
      local index = math.random(1, #weather)
      table.insert(weather, index, self.RAINY)
    end

    local time = last_day and (last_day.t + self.ONE_DAY_SECONDS) or today_start
    for i = 1, 7 do
      table.insert(self.m_serverinfo.days, {w = weather[i], t = time})
      time = time + self.ONE_DAY_SECONDS
    end

    last_day = Tool:last(self.m_serverinfo.days)
  end

  self.m_serverinfo:update()
end

function M:get_current()
  local current_time = os.time();
  local days = self.m_serverinfo.days or {};
  for i, weather in pairs(days) do
    if current_time >= weather.t and current_time < weather.t + self.ONE_DAY_SECONDS then
      return weather.w;
    end
  end

  return self.SUNNY;
end

function M:set_timer( )
  local cb = function()
    self:refresh()
  end
  timer:add_timer(nil, self.ONE_DAY_SECONDS, 1, cb)
end

function M:get(key)
  if type(key) == "string" then
    return self[key]
  end
end

function M:is_current_rainy()
  if self.is_debug == nil then
    self.is_debug = game_cmd:exc_server_cmd("server_info_mgr", "is_debug")
  end
  
  return self.is_debug or self:get_current() == self.RAINY
end

return M