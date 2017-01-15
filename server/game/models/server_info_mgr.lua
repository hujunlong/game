local skynet = require "skynet"
local M = {}

local DEFAULT = {
  zone_pos = {1, 2},
  used_zone_pos = {},
  user_inc = 0,
  days = {},
  gamble_produce = {},
  buildings = {},
  high_ogift_times = 0,
  first_explore_10floor = 0,
  first_vist_temple = 0,
  first_gather_over = 0,
  online_gift_proc = {},
  gem_mine_refresh_times = {
    [1] = 0,  -- area 1
    [2] = 0,  -- area 2
    [3] = 0,  -- area 3
    [4] = 0,  -- area 4
    [5] = 0,  -- area 5
    [6] = 0,  -- area 6
  },
  identifier = "",
  zone = "en",
}

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:factory( params )
  if not params._id or params._id == 0 then
    params._id = Tool:guid()
  end
  Tool:add_merge({params, DEFAULT})
  return self:new(params)
end

function M:update(  )
  skynet.send('database', 'lua', 'server', 'update', Tool:clone(self))
  -- ffi.C.update('servers', cjson.encode({_id = self._id}), cjson.encode(self:attributes()))
  return true
end

function M:attributes(  )
  local attrs = {}
  for i,v in pairs(DEFAULT) do
    if not string.find(i, "__") and type(v) ~= "function" then
      attrs[i] = self[i]
    end
  end
  attrs = Tool:clone(attrs)
  return attrs
end

function M:get_time_gift_finish_time(  )
  return false
end

function M:add_gamble_produce( item )
  return false
end

function M:record_building( user_id, config_id, level )
  if not self.buildings[tostring(config_id)] then
    self.buildings[tostring(config_id)] = {}
  end
  if not self.buildings[tostring(config_id)][tostring(level)] then
    self.buildings[tostring(config_id)][tostring(level)] = user_id
  end 
  self:update()
  return true   
end

function M:assert_first_build( user_id, config_id, level )
  if not self.buildings[tostring(config_id)] then
    return false
  end
  if not self.buildings[tostring(config_id)][tostring(level)] then
    return false
  end
  if self.buildings[tostring(config_id)][tostring(level)] ~= user_id then
    return false
  end
  return true
end

function M:record_server_exlore(user_id)
  if self.first_explore_10floor ~= 0 then 
    return false 
  end
  self.first_explore_10floor = user_id
  self:update()
  return true
end
function M:assert_first_explore(user_id)
  return user_id == self.first_explore_10floor
end

function M:record_server_temple(user_id)
  if self.first_vist_temple ~= 0 then 
    return false 
  end
  self.first_vist_temple = user_id
  self:update()
  return true
end
function M:assert_first_vist_temple(user_id)
  return user_id == self.first_vist_temple
end

function M:record_server_gatherover(user_id)
  if self.first_gather_over ~= 0 then 
    return false 
  end
  self.first_gather_over = user_id
  self:update()
  return true
end
function M:assert_first_gatherover(user_id)
  return user_id == self.first_gather_over
end

function M:get(key)
  return self[key]
end

function M:inc_user()
  self.user_inc = self.user_inc + 1
  self:update()
  return self.user_inc
end

function M:inc_high_ogift_times()
  self.high_ogift_times = self.high_ogift_times + 1
  self:update()
  return true
end

function M:cache_from_db(res)
    if res then
      return M:factory(res)
    else
      return M:set_default_server()
    end
    --Weather:refresh()
end

function M:set_default_server()
    local data_from_db = {
      zone_pos = {
        1,
        1
      },
      user_inc = 1,
      days = {
        {t = 1444981036, w = 1}
      },
      used_zone_pos = { },
      gamble_produce = {}
    }
    return M:factory(data_from_db)
end

function M:is_debug()
  return false
end

--return: true小地图21x21区域, false大地图40x40区域
function M:is_test_server()
  return true
end

function M:is_line_map()
  return not require('ip_config').open_map
end

function M:skip_story()
  return require('ip_config').skip_story == true
end

function M:enable_cave()
  return false
end

function M:enable_rain_boss()
  return false
end

function M:add_online_reward_msg( msg )
  table.insert(self.online_gift_proc, msg)
  if #self.online_gift_proc > 10 then
    self.online_gift_proc[1] = nil
    Tool:delete(self.online_gift_proc, function ( r )
      return r == nil
    end)
  end
  return true
end

function M:get_online_reward_msgs(  )
  return self.online_gift_proc
end

--刷新钻石矿
function M:get_gem_refresh_time(area_id)
  if area_id >= 1 and area_id <= 6 then
    return self.gem_mine_refresh_times[area_id]
  end

  return 0
end

function M:set_gem_refresh_time(area_id, time)
  if area_id >= 1 and area_id <= 6 then
    self.gem_mine_refresh_times[area_id] = time
    self:update()
    return true
  end

  return false
end

function M:get_info(  )
  return {zone = self.zone, identifier = self.identifier}
end

function M:get_login_info()
  return {
        server_time = os.time(),
        time_zone = self:get_time_zone(),
        is_test = self:is_test_server(),
        is_line_map = self:is_line_map(),
        enable_cave = self:enable_cave(),
        skip_story = self:skip_story()
      }
end

return M