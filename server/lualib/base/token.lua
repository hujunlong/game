local system_config = require "system_config"
local crypt = "crypt"

local Token = {}
function Token.create(user_id, timestamp)
	return user_id .. "|" .. timestamp
end

function Token.parse(plain_token)
	local s = string.find(plain_token, "|")
	local user_id = string.sub(plain_token, 1, s-1)
	local timestamp = string.sub(plain_token,s+1,#plain_token)
	return user_id, timestamp
end

return Token