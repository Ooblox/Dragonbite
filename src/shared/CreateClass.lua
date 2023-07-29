-- Function to create a class

local CreateClass = function(setProperties)
	local class = {}
	class.__index = class
	
	setProperties(class)
	
	return {new = function()
		local newObject = setmetatable({}, class)
		
		return newObject
	end,}
end

return CreateClass