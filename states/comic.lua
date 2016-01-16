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

function Comic.draw(self)
	local sc = self.currentscene
	
	if sc ~= nil then
		if self.settings.view3D then
			local eyedist = self.settings.eyeDistance
			sc:draw(self.lefteye, eyedist/2)
			sc:draw(self.righteye, -eyedist/2)
			
			love.graphics.draw(self.righteye, 0, 0)
			love.graphics.draw(self.lefteye, love.graphics.getWidth()/2, 0)
		else
			sc:draw(self.mainCanvas)
			
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
	self.currentscene.paused = false
end

return Comic