-- OPTIONS.LUA - draws and handles the options menu

local Options = {}
Options.__index = Options

local minima = {}
local maxima = {}
minima.volume = 0; maxima.volume = 1
minima.eyeDistance = 0.02; maxima.eyeDistance = 0.1

local drawTypes = {}
local drawFunctions = {}

function Options.new(parent)
	local self = setmetatable({}, Options)
	
	self.parent = parent
	self.options = {}
	for key, value in pairs(getSettings()) do
		self.options[key] = value
	end
	self.items = {}
	
	for key, value in pairs(self.options) do
		local functionName = "text"
		if key == "volume" or key == "eyeDistance" then functionName = "slider" end
		drawTypes[key] = functionName
	end
	
	local i = 1
	for key, value in pairs(self.options) do
		self.items[i] = key
		i = i + 1
	end
	
	local file = {}
	i = 1
	for line in io.lines(love.filesystem.getSourceBaseDirectory().."/arc9ne/defaultsettings.txt") do
		file[i] = line
		i = i + 1
	end
	local sortFunction = function(a, b)
		local aFind = nil
		local bFind = nil
		
		for j=1, #file do
			if startsWith(file[j], a.."=") then
				aFind = j
				if bFind ~= nil then break end
			end
			if startsWith(file[j], b.."=") then
				bFind = j
				if aFind ~= nil then break end
			end
		end
		
		if aFind == nil or bFind == nil then return true end
		return aFind < bFind
	end
	table.sort(self.items, sortFunction)
	
	return self
end

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
		
		local drawFunction = drawFunctions[drawTypes[self.items[i]]]
		local value = tostring(self.options[self.items[i]])
		if drawFunction ~= nil and value ~= nil then
			drawFunction(value, w*0.45, h*y, self.items[i])
		end
	end
	love.graphics.pop()
	
	--drawText("esc to cancel, space/enter to save", 20, h-30, "left")
end

function Options.increment(self, amount)
	local key = self.items[self.parent.selected]
	local value = self.options[key]
	
	if value == true or value == false then -- option is a boolean
		self.options[key] = not value
	end
	
	if tonumber(value) ~= nil then -- option is a number
		if drawTypes[key] == "slider" then
			local incr = {}
			incr.volume = 0.2
			incr.eyeDistance = 0.02
			
			if incr[key] == nil then
				self.options[key] = tonumber(value) + amount
			else
				self.options[key] = tonumber(value) + amount*incr[key]
			end
			if self.options[key] > maxima[key] then self.options[key] = maxima[key] end
			if self.options[key] < minima[key] then self.options[key] = minima[key] end
		end
	elseif key == "resolution" then
		local resolutions = {"640x480", "800x600", "1200x900", "1600x1200"}
		local index = 2 -- default value
		for i=1,#resolutions do
			if resolutions[i] == value then index = i end
		end
		
		if amount > 0 then
			index = index + 1
			if index > #resolutions then index = #resolutions end
		else
			index = index - 1
			if index < 1 then index = 1 end
		end
		
		self.options[key] = resolutions[index]
	end
	
	if key == "volume" then
		if value == 0 and self.options.volume > 0 then love.audio.resume() end
		love.audio.setVolume(self.options[key])
	end
end

function Options.updateSettings(self)
	local w = self.options.width
	local h = self.options.height
	self.options = getSettings()
	
	if w ~= self.options.width or h ~= self.options.height then resizeWindow() end
	love.audio.setVolume(self.options.volume)
end

return Options