local M = {}

Tool = M
log = log or require "logger"
local skynet = require "skynet"
local bson = require "bson"
local pack = pack or table.pack
local unpack = unpack or table.unpack

function Tool:merge(tables)
	local first = tables[1]
	if not first then return {} end
	for key, table in pairs(tables) do
		if key ~= 1 then
			for k, v in pairs(tables) do
				first[k] = v
			end
		end
	end
	return first
end

function Tool:objectid_s()
	return Tool:objectid2str(bson.objectid())
end

local tinsert = table.insert
local sbyte = string.byte
local sformat = string.format
function Tool:objectid2str(object_id)
	assert(type(object_id) == 'string' and string.len(object_id) == 14)
	local t = {}
	for i =3, 14 do
		local byte = sbyte(object_id, i)
		local hight = (byte >> 4) & 0x0f
		local low = byte & 0x0f
		s = sformat('%x%x', hight, low)
		tinsert(t, s)
	end
	return table.concat(t)
end

return M