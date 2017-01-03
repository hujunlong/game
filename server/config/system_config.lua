local common = {
	client_aes_key = 's23werewr$3',
	auth_des_encript_key = '2f45a8_9',
	shutdown_verify = "sdfjh_32424_sacxvnuiqwp_cvcve3234",
	client_port = 7000,
}

local debug = {
	log_level = 1,
	db_gc = false,
	max_offline_agent = 200,
	max_db_client = 2,
	time_waiting_exit = 100 * 5,
	cache_pool_size = 100,
	enable_replay = true,
	launch_test_service = false,
	enable_robot = false,
}

local release = {
	log_level = 2,
	db_gc = true,
	max_offline_agent = 200,
	max_db_client = 2,
	time_waiting_exit = 100 * 5,
	cache_pool_size = 10000,
	enable_replay = false,
	launch_test_service = false,
	enable_robot = false,
}

for k, v in pairs(common) do
	debug[k] = v
	release[k] = v
end

local config = debug
return config