local M = ConfigBase:new()

ConfigBuffItem = M

M:set_origin(config_buff_items)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:used( user, opts )
  opts = opts or {}
  opts.amount = opts.amount or 1
  local cb = ConfigBuff:find_by_id(self.buff)
  local time = cb.time * opts.amount
  if opts.building_id then
    local building = user:find_building_by_id(opts.building_id)
    building.speed.start_time = os.time()
    building.speed.finish_time = os.time() + time
    building.speed.num = cb.effect
    return nil, {buildings = {{uid = building:get_uid(), speed = building.speed, specs = building:get_spec_info()}}}
  else
    if cb.buff == 8507 and user:being_attacked() then
      return {error = 'can_not_protect_when_attacked'}
    end
    user:add_buff(self._id, cb.buff, time, cb._id)
    local push_msg = user:get_buffs_info()
    if cb.buff == 8510 then   -- 部队出征上限提高
      push_msg.users = {
        [1] = {
          uid = user:get_uid(),
          max_armies = user:get_max_march_armies_amount(),
        },
      }
    end
    return nil, push_msg
  end  
end

M:load()

return M
