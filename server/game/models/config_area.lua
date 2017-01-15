local skynet = require "skynet"

local M = ConfigBase:new()

ConfigArea = M

M:set_origin(config_areas)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:load(  )
  self.__records = {}
  self.__areas = {}
  for k, v in ipairs(self:get_origin()) do
    local config = self:new(v)
    config:init()
    self.__records[v._id] = config
    self.__areas[v.area] = config
    table.insert(self.__srecords, config)
  end
end

function M:find_by_area( area )
  if self.__areas[area] then
    return self.__areas[area]
  end
end

function M:init()
  self.__positions = {}
  self.__resource_count = {}
end

function M:init_armies( )
  local result = {}
  for k, info in pairs(self:get_monsters()) do
    local config_army = ConfigArmy:find_by_level(info.level)
    if config_army then
      for i = 1, info.count do
        table.insert(result, {level = config_army.level, monsters = config_army:refresh()})
      end
    end
  end

  return result 
end

function M:get_monsters( )
  if not self.__monsters then
    self.__monsters = {}
    
    if self.monster ~= 0 then
      local t = Tool:split(self.monster, '-')
      local total_count = t[1]
      local other = t[2]
      for k, str in pairs(Tool:split(other, ',')) do
        local info = Tool:split(str, ':')
        local level = tonumber(info[1])
        local count = math.floor(total_count * tonumber(info[2]) / 100 + 0.5);
        table.insert(self.__monsters, { level = level, count = count })
      end
    end
  end

  return self.__monsters
end

function M:get_resource_count_info(resource_type)
  if not self.__resource_count[resource_type] then
    self.__resource_count[resource_type] = {};

    local total_count = self.resource;
    local config = self[resource_type];
    local total_remain = total_count

    if total_count ~= 0 and config ~= nil and config ~= 0 then
      local configs = Tool:split(config, '-');
      local resource_count = math.floor(total_count * tonumber(configs[1]) / 100 + 0.5);
      resource_count = math.min(total_remain, resource_count)
      total_remain = total_remain - resource_count
      local remain = resource_count
      for k, v in ipairs(Tool:split(configs[2], ',')) do
        local info = Tool:split(v, ':');
        local level = tonumber(info[1]);
        local count = math.floor(resource_count * tonumber(info[2]) / 100 + 0.5);
        count = math.min(remain, count)
        remain = remain - count
        table.insert(self.__resource_count[resource_type], {level = level, count = count});
      end
    end
  end

  return Tool:clone(self.__resource_count[resource_type]);
end

function M:get_zone_area_id(zone)
  if self.is_line_map == nil then
    self.is_line_map = game_cmd:exc_server_cmd("server_info_mgr", "is_line_map")
  end
  if self.is_line_map then
    if (zone.x >= 1 and zone.x <= MapConst.MAP.ZONE_WIDTH) and zone.y == 4 then
      return MapConst.MAP.AREA_5
    elseif (zone.x >= 1 and zone.x <= MapConst.MAP.ZONE_WIDTH) and zone.y == 3 then
      return MapConst.MAP.AREA_4
    elseif (zone.x >= 1 and zone.x <= MapConst.MAP.ZONE_WIDTH) and zone.y == 2 then
      return MapConst.MAP.AREA_3
    else
      return MapConst.MAP.AREA_2
    end
  end

  local area_id = MapConst.MAP.AREA_1;
  local zone_width, zone_height = MapConst.MAP.ZONE_WIDTH, MapConst.MAP.ZONE_HEIGHT
  local area_top_left = WildConst.AREA_TOP_LEFT

  for area_id = MapConst.MAP.AREA_1, MapConst.MAP.AREA_5 do
    local next_area = area_top_left[area_id + 1]
    if zone.x < next_area.x or zone.x > zone_width - (next_area.x - 1)
        or zone.y < next_area.y or zone.y > zone_height - (next_area.y - 1) then
      return area_id
    end
  end

  return MapConst.MAP.AREA_6
end

function M:get_positions(key)
  if not self.__positions[key] then
    self.__positions[key] = {};

    if self[key] ~= 0 then
      local positions = Tool:split(self[key], ',');
      for i, v in ipairs(positions) do
        local position = tonumber(v) - 1;
        local x = math.floor(position % MapConst.MAP.ZONE_SIZE);
        local y = math.floor(position / MapConst.MAP.ZONE_SIZE);
        table.insert(self.__positions[key], {x = x, y = y});
      end
    end
  end

  return Tool:clone(self.__positions[key]);
end

function M:get_resource_positions()
  return self:get_positions("res_position");
end

function M:get_player_positions()
  return self:get_positions("player_position");
end

function M:get_monster_positions()
  return self:get_positions("monster_position");
end

function M:get_mine_period(mine_name)
  if not self.__period then
    self.__period = {}
    if self.mine_period ~= 0 then
      local periods = Tool:split(self.mine_period, ',')
      for i, v in ipairs(periods) do
        local info = Tool:split(v, ':')
        local name = info[1]
        local hour = tonumber(info[2])
        self.__period[name] = hour
      end
    end
  end

  return self.__period[mine_name] or 60
end

function M:get_teleport_level()
  return self.teleport_level
end

function M:get_land_positions()
  local key = 'land_position'

  if not self.__positions[key] then
    self.__positions[key] = {};

    local count = MapConst.MAP.ZONE_SIZE * MapConst.MAP.ZONE_SIZE
    local positions = {}
    local mark_positions = function(key)
      if self[key] ~= 0 then
        local list = Tool:split(self[key], ',')
        for k, v in pairs(list) do
          positions[tonumber(v)] = true
        end
      end
    end

    mark_positions("res_position")
    mark_positions("player_position")
    mark_positions("monster_position")
    for i = 1, count do
      if not positions[i] then
        local position = i - 1;
        local x = math.floor(position % MapConst.MAP.ZONE_SIZE);
        local y = math.floor(position / MapConst.MAP.ZONE_SIZE);
        table.insert(self.__positions[key], {x = x, y = y});
      end
    end
  end

  return Tool:clone(self.__positions[key]);
end

M:load()

return M
