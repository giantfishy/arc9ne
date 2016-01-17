local Scene = require('../scene')

local Comic = {}
Comic.__index = Comic

function Comic.new(settings)
	local self = setmetatable({}, Comic)
	self.settings = settings
	self.currentscene = nil
	
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	
	self.mainCanvas = love.graphics.newCanvas(w, h)
	self.lefteye = love.graphics.newCanvas(w/2, h)
	self.righteye = love.graphics.newCanvas(w/2, h)
	
	return self
end

function Comic.load(self, filename)
	self.currentscene = Scene.new(filename)
end

function Comic.draw(self)
	local sc = self.currentscene
	
	if sc ~= nil then
		if self.settings.view3D then
			local eyedist = self.settings.eyeDistance
			local smooth = self.settings.smoothMovement
			sc:draw(self.lefteye, eyedist/2, smooth)
			sc:draw(self.righteye, -eyedist/2, smooth)
			
			love.graphics.draw(self.righteye, 0, 0)
			love.graphics.draw(self.lefteye, love.graphics.getWidth()/2, 0)
		else
			sc:draw(self.mainCanvas, 0, smooth)
			
			love.graphics.draw(self.mainCanvas, 0, 0)
		end
	end
end

function Comic.update(self, dt)
	local sc = self.currentscene
	
	if sc ~= nil then
		local finished = sc:update(dt)
		if finished then
			-- go to the next one?
		end
	end
end

function Comic.keypressed(self, key)
	if key == "space" then
		self.currentscene.paused = false
	elseif key == "3" then
		self.settings.view3D = not self.settings.view3D
	elseif key == "s" then
		self.settings.smoothMovement = not self.settings.smoothMovement
	end
end

return Comic