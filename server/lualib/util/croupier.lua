local class = class or require "class"
local croupier = class("croupier")

local epsilon = 1e-4
local two_pi = 2.0*3.1415926535
local max_float = 1e10

local function normalize_random(self, mu, sigma)
	if self.generate then
		self.generate = false
		return self.z1 * sigma + mu
	else
		self.generate = true
	end

	local u1, u2
	repeat
		u1 = math.random()
		u2 = math.random()
	until u1 <= epsilon

	self.z0 = math.sqrt(-2.0 * math.log(u1)) * math.cos(two_pi * u2)
	self.z1 = math.sqrt(-2.0 * math.log(u1)) * math.cos(two_pi * u2)
	return self.z0 * sigma + mu
end 

local function random_f(self)
	local minp = max_float
	local minp_i = -1
	for i,v in pairs(self.pool) do
		if v < minp then
			minp = v
			minp_i = i
		end
	end

	for i,v in pairs(self.pool) do
		self.pool[i] = self.pool[i] - minp
	end

	self.pool[minp_i] = normalize_random(self, 1/self.weight_array_p[minp_i], 1/self.weight_array_p[minp_i]/3)
	return minp_i
end


function croupier:ctor(conf)
	self._id = conf._id
	
	if conf.weight_array then
		-- first init

		-- parameter checking, there should be no zeore in weight_array
		for i,v in ipairs(conf.weight_array) do
			assert(v ~= 0, "weight_array doesn't accept 0")
		end

		self.weight_array = conf.weight_array
		local sum = 0
		for i, v in ipairs(conf.weight_array) do
			sum = sum + conf.weight_array[i]
		end
		assert(sum ~= 0, "sum of a pool can not be 0.")

		local weight_array_p = {}
		for i, v in ipairs(conf.weight_array) do
			weight_array_p[i] = v / sum
		end

		self.z0 = 0.0
		self.z1 = 0.0
		self.generate = false
		self.weight_array_p = weight_array_p

		local pool = {}
		for i, v in ipairs(weight_array_p) do
			pool[i] = normalize_random(self, 1/v, 1/v/3)
		end
		self.pool = pool
	else
		-- load from database
		self.z0 = conf.z0
		self.z1 = conf.z1
		self.generate = conf.generate
		self.pool = conf.pool
		self.weight_array_p = conf.weight_array_p
	end
end

function croupier:deal()
	return random_f(self)
end

function croupier:tablize()
	return {
			_id = self._id,
			z0 = self.z0,
			z1 = self.z1,
			generate = self.generate,
			pool = self.pool,
			weight_array_p = self.weight_array_p,
		   }
end

function croupier:__tostring()
	return string.format('[croupier] id = [%s], pool = [%s]', self._id, table.concat(self.pool, ','))
end

return croupier