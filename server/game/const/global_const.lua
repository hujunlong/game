local def = {}
global = def 
def.map_data = {} 
def.map_data.ZONE_INDEX_TOP_LEFT = 1;
def.map_data.ZONE_INDEX_TOP_RIGHT = 2;
def.map_data.ZONE_INDEX_BOTTOM_LEFT = 3;
def.map_data.ZONE_INDEX_BOTTOM_RIGHT = 4;
def.map_data.ZONE_INDEX_COUNT = 4;
def.map_data.last_build_index = def.map_data.ZONE_INDEX_TOP_LEFT;
def.map_data.last_build_zone = {
	[def.map_data.ZONE_INDEX_TOP_LEFT] = {x = 1, y = 1},
	[def.map_data.ZONE_INDEX_TOP_RIGHT] = {x = 40, y = 1},
	[def.map_data.ZONE_INDEX_BOTTOM_RIGHT] = {x = 40, y = 40},
	[def.map_data.ZONE_INDEX_BOTTOM_LEFT] = {x = 1, y = 40}
};

def.table = {
	t_map = "maps",
	t_unions = "unions",
	t_account="account",
	t_mail = "mail",
}

def.timer_id = {re_login_timer = 3000}

return def

