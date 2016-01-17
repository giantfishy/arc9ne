-- SPRITE.LUA - an image with a location in (pseudo)3D space. knows how to draw itself

local Sprite = {}
Sprite.__index = Sprite

local g = love.graphics

function Sprite.new(img, x, y, parallax)
	local self = setmetatable({}, Sprite)
	self.img = img
	self.x = x
	self.y = y
	self.parallax = parallax
	
	return self
end

function Sprite.draw(self, offset_x, offset_y, smooth)
	local coords = getScreenCoords(offset_x, offset_y, self.parallax)
	local w = self.img:getWidth()
	local h = self.img:getHeight()
	
	local draw_x = coords[1] + self.x*love.graphics.getWidth()/2
	local draw_y = coords[2] + self.y*love.graphics.getHeight()/2
	
	if not smooth then
		draw_x = math.floor(draw_x)
		draw_y = math.floor(draw_y)
	end
	
	g.draw(self.img, draw_x, draw_y, 0, 1, 1, w/2, h/2)
end

function getScreenCoords(offset_x, offset_y, parallax)
	local screenx = (1 + parallax*offset_x) / 2
	local screeny = (1 + parallax*offset_y) / 2
	
	return {screenx * love.graphics.getWidth(), screeny * love.graphics.getHeight()}
end

return Sprite