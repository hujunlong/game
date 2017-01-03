local sprotoloader = require "sprotoloader"
local sprotoparser = require "sprotoparser"
local login_proto = require "login_proto"
local game_proto = require "game_proto"

local protoloader = {
	LOGIN_C2S = 3,
	LOGIN_S2C = 4,

	GAME_C2S = 3,
	GAME_S2C = 4,
}

function protoloader.load(index)
	return sprotoloader.load(index)
end

function protoloader.init()
	local protoes = {login_proto.c2s, login_proto.s2c, game_proto.c2s, game_proto.s2c}
	for i = 1, #protoes do
		sprotoloader.save(sprotoparser.parse(protoes[i]), i)
	end
end

return protoloader