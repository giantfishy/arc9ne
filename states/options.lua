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
	alias.view3D = "3D mode"
	alias.eyeDistance = "3D intensity"
	
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
	
	setFont("selected")
	drawText("options", w-30, 30, "right")
	setFont("small")
	drawText("space/enter to save, esc to cancel, r to reset to defaults", w-30, h-30, "right")
end

function Options.increment(self, amount)
	local key = self.items[self.parent.selected]
	local value = self.options[key]
	
	if value == true or value == false then -- option is a boolean
		self.options[key] = not value
		return
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
	else -- choose from list of strings
		local listData = {}
		listData.resolution = {list={"640x480", "800x600", "1200x900", "1600x1200"}, def=2, cycle=false}
		listData.view3D = {list={"off", "crossview", "3D viewer"}, def=1, cycle=true}
		
		local data = listData[key]
		
		local index = data.def -- default value
		for i = 1, #data.list do
			if data.list[i] == value then
				index = i
				break
			end
		end
		
		if amount > 0 then
			index = index + 1
			if index > #data.list then
				if data.cycle then index = 1 else index = #data.list end
			end
		else
			index = index - 1
			if index < 1 then
				if data.cycle then index = #data.list else index = 1 end
			end
		end
		
		self.options[key] = data.list[index]
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
	if self.options.volume ~= 0 then love.audio.resume() end
end

return Options