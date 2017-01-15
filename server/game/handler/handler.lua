local class = class or require "class"
local M = class("handler")
local log = require('logger')
local Tool = require('tool')

Handler = M

function M:ctor()
  self.__data = {}
end

function M:render(o, status)  
  o.status = status or 200
  -- log.dr(o)
  return o
end

function M:error( key, et, opts)
  et = et or ErrorConst.NORMAL
  local msg = {
    error = key,
    error_type = et
  }
  opts = opts or {}
  Tool:merge({msg, opts})
  return self:render(msg, 298)
end

function M:error_code(key, ...)
  local config_error = config_errors[key]
  if config_error then
    return self:render({}, config_error._id)
  else
    return self:render({ 
        error = key,--I18n:t(key, self.session:get("locale"), ...) or key.." is not translated, please report it to server !", 
      }, 298
    )
  end
end
function M:handle( err, info )
  if err then
    self:error(err)
  else
    self:render(info)  
  end  
end

function M:set_current_user(user)
  self.m_current_user = user
end

function M:error_price( price )
  if price.type == BasicConst.CURRENCY.GEM then
    return self:error('not_enough_gems')
  elseif price.type == BasicConst.CURRENCY.UNION_CONTRI then
    return self:error('not_enough_union_contribution')
  elseif price.type == BasicConst.CURRENCY.PERSON_UNION_CONTRI then
    return self:error('not_enough_person_union_contribution')
  else
    return self:error('not_enough_currency')
  end    
end

return M