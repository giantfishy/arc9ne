-- COMIC.LUA - for drawing any scenes from the comic itself

local Scene = require('../scene')

local Comic = {}
Comic.__index = Comic

function Comic.new()
	local self = setmetatable({}, Comic)
	self.settings = getSettings()
	self.currentscene = nil
	
	self:makeCanvases()
	
	return self
end

function Comic.makeCanvases(self)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	
	if self.settings.fullscreen == true then
		if self.settings.view3D == false then
			w = 4 * h / 3
		else
			h = 3 * w / 8
		end
	end
	
	self.mainCanvas = love.graphics.newCanvas(w, h)
	self.lefteye = love.graphics.newCanvas(w/2, h)
	self.righteye = love.graphics.newCanvas(w/2, h)
end

function Comic.load(self, filename)
	self.currentscene = Scene.new(filename)
end

function Comic.draw(self)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	local sc = self.currentscene
	
	if self.mainCanvas == nil or self.lefteye == nil or self.righteye == nil then
		self:makeCanvases()
	end
	
	if sc ~= nil then
		local smooth = self.settings.smoothMovement
		if self.settings.view3D then
			local eyedist = self.settings.eyeDistance
			sc:draw(self.lefteye, eyedist/2, smooth)
			sc:draw(self.righteye, -eyedist/2, smooth)
			
			love.graphics.draw(self.righteye, w*0.25, h*0.5, 0, 1, 1, self.righteye:getWidth()/2, self.righteye:getHeight()/2)
			love.graphics.draw(self.lefteye, w*0.75, h*0.5, 0, 1, 1, self.lefteye:getWidth()/2, self.lefteye:getHeight()/2)
		else
			sc:draw(self.mainCanvas, 0, smooth)
			
			love.graphics.draw(self.mainCanvas, w*0.5, h*0.5, 0, 1, 1, self.mainCanvas:getWidth()/2, self.mainCanvas:getHeight()/2)
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
	if key == "space" or key == "return" or key == "kpenter" then
		self.currentscene.paused = false
	end
end

return Comic