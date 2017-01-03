local aes = require "aes"
local system_config = require "system_config"
local crypt = require "crypt"
local bson = require "bson"

local DB_Account = {
	ERROR_PASSWORD_NOT_MATCH = 1,
	ERROR_USERNAME_ALERADY_EXIST = 2,
}

local col_get_func

function DB_Account.init(get_func)
	col_get_func = get_func
end

function DB_Account.cheak(user_id)
	assert(user_id)
	log.i('[DB_Account] check user_id = ' .. user_id)
	local collection = col_get_func('account', user_id)
	local ret = collection:findOne({_id = user_id})
	if not ret then
		print('[DB_Account] no user found.')
		return false
	else
		print('[DB_Account] user exists . can return.')
		return true
	end
end

function DB_Account.save(user, plain_user_id)
	local collection = col_get_func('account', plain_user_id)
	collection:update(user, user, true)
end

return DB_Account