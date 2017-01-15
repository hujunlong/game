
local M = {}

local DEFAULT = {
  _id = 0,
  k = 0,
  x = 0,
  y = 0,
  t = 0, --类型
  desc = '',
  time = 0
}

Bookmark = M

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:factory( params, user )
  Tool:add_merge({params, DEFAULT})
  if not params._id or params._id == 0 then
    user.keys.bookmark = user.keys.bookmark + 1
    params._id = user.keys.bookmark
  end
  params.time = os.time()
  return self:new(params)
end

function M:get_info(  )
  return {
    uid = self._id,
    k = self.k,
    x = self.x,
    y = self.y,
    t = self.t, --类型,
    desc = self.desc,
    time = self.time
  }
end

return M

