local Options = {}
Options.__index = Options

local drawFunctions = {}
drawFunctions.text = function(value, x, y, name)
	if value == "true" then value = "yes" end
	if value == "false" then value = "no" end
	setFont("menuItem")
	love.graphics.setColor(120, 230, 200)
	drawText(value, x, y, "left")
	love.graphics.setColor(255, 255, 255)
end
drawFunctions.slider = function(value, x, y, name)
	-- bot & top = min & max
	local w = love.graphics.getWidth() * 0.2
	local h = 10
	
	local minima = {}
	local maxima = {}
	minima.volume = 0; maxima.volume = 1
	minima.eyeDistance = 0.02; maxima.eyeDistance = 0.1
	
	local bot = minima[name]
	local top = maxima[name]
	if bot == nil or top == nil then
		bot = 0
		top = 1
	end
	
	local percent = ((tonumber(value) - bot) / (top - bot))
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", x, y-h/2, w, h)
	love.graphics.setColor(120, 230, 200)
	love.graphics.rectangle("fill", x - h*percent + w*percent, y - h/2, h, h)
	love.graphics.setColor(255, 255, 255)
end

function Options.new(parent)
	local self = setmetatable({}, Options)
	
	self.parent = parent
	self.options = getSettings()
	self.items = {}
	
	-- TODO: order list based on the order they appear in settings.txt
	local i = 1
	for key, value in pairs(self.options) do
		self.items[i] = key
		i = i + 1
	end
	
	return self
end

function Options.draw(self)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	
	love.graphics.push()
	love.graphics.translate(0, self.parent.y * h * -0.05)
	
	local alias = {} -- translate from variable name to more readable option name
	alias.skipSplash = "skip splash screen"
	alias.view3D = "crossview 3D"
	alias.eyeDistance = "3D intensity"
	alias.smoothMovement = "smooth movement"
	
	for i=1, #self.items do
		local y = 0.5 + (i * 0.05)
		if i < self.parent.selected then
			y = y - 0.05
		elseif i > self.parent.selected then
			y = y + 0.05
		end
		--if i == self.parent.selected then setFont("selected") else setFont("menuItem") end
		setFont("menuItem")
		
		local item = alias[self.items[i]]
		if item == nil then item = self.items[i] end
		drawText(item, w*0.4, h*y, "right")
		
		local drawTypes = {}
		for key, value in pairs(self.options) do
			local functionName = "text"
			if key == "volume" or key == "eyeDistance" then functionName = "slider" end
			drawTypes[key] = functionName
		end
		local drawFunction = drawFunctions[drawTypes[self.items[i]]]
		local value = tostring(self.options[self.items[i]])
		if drawFunction ~= nil and value ~= nil then
			drawFunction(value, w*0.45, h*y, self.items[i])
		end
	end
	love.graphics.pop()
	
	--drawText("esc to cancel, space/enter to save", 20, h-30, "left")
end

return Options