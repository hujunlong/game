local M = ConfigBase:new()

ConfigGamblingPrize = M

M:set_origin(config_gambling_prizes)

M.LOW = 1
M.MID = 2
M.HIGH = 3

local PERSON = 1
local UNION = 2

function M:get_items(  )
  if self.__items then return self.__items end
  self.__items = Tool:map(Tool:split(self.prizes, ','), function ( str )
    local t = Tool:split(str, ':')
    return {item_id = tonumber(t[1]), amount = tonumber(t[2])}
  end)
  return self.__items
end                                                                                                                                                                                    

function M:get_person(  )
  if self.__person then return self.__person end
  self.__person = Tool:select(self:sall(), function ( r )
    return r.type == PERSON
  end)
  return self.__person
end

function M:get_union(  )
  if self.__union then return self.__union end
  self.__union = Tool:select(self:sall(), function ( r )
    return r.type == UNION
  end)
  return self.__union
end

function M:get_union_chances( )
  if self.__union_chances then return self.__union_chances end
  self.__union_chances = {}
  for k,v in pairs(self:get_union()) do
    self.__union_chances[v.level] = v.chance
  end
  return self.__union_chances
end

function M:get_person_chances( )
  if self.__chances then return self.__chances end
  self.__chances = {}
  for k,v in pairs(self:get_person()) do
    self.__chances[v.level] = v.chance
  end
  return self.__chances
end

function M:find_by_person_level( level )
  return Tool:find(self:get_person(), function ( r )
    return r.level == level
  end)
end

function M:find_by_union_level( level )
  return Tool:find(self:get_union(), function ( r )
    return r.level == level
  end)
end

M:load()

return M
