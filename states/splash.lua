-- SPLASH.LUA - the splash screen, drawn when the program starts up

local Splash = {}
Splash.__index = Splash

local fadeTime = 0.5 -- time it takes for an image to fade in/out
local imageTime = 2.5 -- total time an image is on screen

function Splash.new()
	local self = setmetatable({}, Splash)
	self.images = {}
	local imageNames = {"logo.png", "love2d.png"}
	for i=1,#imageNames do
		self.images[i] = love.graphics.newImage("splash/"..imageNames[i])
	end
	
	self.time = 0
	
	return self
end

function Splash.draw(self)
	local i = math.ceil(self.time / imageTime) -- which image should be displayed
	
	local midImage = imageTime / 2
	local alpha = 1 - math.abs((self.time % imageTime) - midImage) / midImage
	alpha = alpha / fadeTime
	if alpha > 1 then alpha = 1 end
	love.graphics.setColor(255, 255, 255, alpha*255)
	
	if i <= #self.images then
		local img = self.images[i]
		local w = img:getWidth()
		local h = img:getHeight()
		love.graphics.draw(img, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, 1, 1, w/2, h/2)
	end
	love.graphics.setColor(255, 255, 255)
end

function Splash.update(self, dt)
	self.time = self.time + dt
	if self.time >= #self.images * imageTime then
		changeState("comic")
		loadScene("act1/scene1")
	end
end

function Splash.keypressed(self, key)
	self.time = math.ceil(self.time / imageTime) * imageTime
end

return Splash