local function class(classname, super)
	local superType = type(super)
	local cls = {}

	if superType ~= "function" and superType ~= "table" then
		superType = nil
		super = nil
	end

	if super then
		setmetatable(cls, {__index = super})
		cls.super = super
		cls.ctor = function() end
	end

	cls.__cname = classname
	cls.__index = cls

	function cls.new(...)
		local instance = setmetatable({}, cls)
		instance:ctor(...)
		return instance
	end
	return cls
end

return class