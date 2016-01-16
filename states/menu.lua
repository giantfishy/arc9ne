local Menu = {}
Menu.__index = Menu

function Menu.new()
	local self = setmetatable({}, Menu)
	
	return self
end

function Menu.draw(self)
	
end

function Menu.update(self, dt)
	
end

function Menu.keypressed(self, key)
	
end

return Menu