skynet_root = "../lib/skynet/"
root = "./"
thread = 8
logger = nil
harbor = 0
start = "main"
bootstrap = "snlua bootstrap"

lua_path = skynet_root .. "lualib/?.lua" ..
		   ";" .. root .. "../common/?.lua" ..
		   ";" .. root .. "config/?.lua" ..

		   ";" .. root .. "lualib/?.lua" ..
		   ";" .. root .. "lualib/db/?.lua" ..
		   ";" .. root .. "lualib/util/?.lua" ..
		   ";" .. root .. "lualib/util/timer/?.lua" ..
		   ";" .. root .. "lualib/util/btree/?.lua" ..
		   ";" .. root .. "lualib/base/?.lua" ..

		   ";" .. root .. "game/startups/?.lua" ..
		   ";" .. root .. "game/config/?.lua" ..
		   ";" .. root .. "game/const/?.lua" ..
		   ";" .. root .. "game/http/?.lua" ..
		   ";" .. root .. "game/handler/?.lua" ..
		   ";" .. root .. "game/models/?.lua" ..
		   ";" .. root .. "game/models/union/?.lua" ..
		   ";" .. root .. "game/models/user/?.lua" ..
		   ";" .. root .. "game/models/wild/?.lua" ..
		   ";" .. root .. "game/models/battleSimulator/?.lua"

lua_cpath = skynet_root .. "luaclib/?.so;" .. root .. "luaclib/?.so"
cpath = skynet_root.."cservice/?.so"
luaservice = skynet_root.."service/?.lua;"..root.."service/?.lua;"..root.."game/?.lua"
lualoader = skynet_root .. "lualib/loader.lua"
snax = skynet_root .. "?.lua;" .. root .. "service/?.lua"