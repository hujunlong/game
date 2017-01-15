local M = ConfigBase:new()

ConfigSpeedItem = M

M:set_origin(config_speed_items)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local COMMON = 1
local BUILD = 2
local RESEARCH = 3
local TRAIN = 4
local CURE = 5
local TRAIN_DEFENCE = 7

function M:used( user, opts )
  opts = opts or {}
  opts.amount = opts.amount or 1
  local time = self.func * opts.amount
  if opts.building_id then
    local building = user:find_building_by_id(opts.building_id)
    if not building.event_id or building.event_id == "" then
      log.w("[speed item]building event is finished!!!!!!")
      return {error = "event_is_finished"}
    end
    if (self.category == BUILD or self.category == COMMON) and building.status == BuildingConst.BUILDING_STATUS.BUILDING then
      building:speed_up_upgrade(time)
    elseif (self.category == TRAIN or self.category == TRAIN_DEFENCE or self.category == COMMON) and building.status == BuildingConst.BUILDING_STATUS.WORK then
      building:speed_up_train(time)
    elseif (self.category == RESEARCH or self.category == COMMON) and building.status == BuildingConst.BUILDING_STATUS.RESEARCH then
      building:speed_up_research(time)
    elseif (self.category == CURE or self.category == COMMON) and building.status == BuildingConst.BUILDING_STATUS.CURE then
      building:speed_up_cure(time)
    end
  end
end

M:load()

return M
