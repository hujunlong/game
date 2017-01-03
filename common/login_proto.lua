--[[
	login protocol

	we may use srp in the future.
	srp can achieve no password login.
	this is commonly used by programmers such as "ssh login".
	
	author: tangyiyang
]]

local login_proto = {}

login_proto.c2s = [[
.package {
	type 0 : integer
	session 1 : integer
}

.server_info {
	name 0 : string
	host 1 : string
	port 2 : integer
}

auth 1 {
	request {
		user_id 0 : string
	}

	response {
		ok 0 : boolean
		error_code 1 : integer
		user_id 2 : string
		token 3 : string
		game_server_info 4: server_info
	}
}


auth_old 2 {
	request {
		username 0 : string		
		password 1 : string		# encrypted password.
	}
	response {
		ok 0 : boolean
		token 1 : string
		error_code 2 : integer
	}
}

]]

login_proto.s2c = [[
.package {
	type 0 : integer
	session 1 : integer
}
]]

return login_proto
