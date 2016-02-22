-- SPRITE.LUA - an image with a location in (pseudo)3D space. knows how to draw itself

local Sprite = {}
Sprite.__index = Sprite

local g = love.graphics

function Sprite.new(img, x, y, z)
	local self = setmetatable({}, Sprite)
	self.img = img
	self.x = x
	self.y = y
	self.z = z
	
	self.keyframer = nil
	
	return self
end

function Sprite.draw(self, canvas, offset_x, offset_y, smooth, scale)
	if scale == nil then scale = 1 end
	local coords = getScreenCoords(canvas, offset_x, offset_y, self.z)
	local w = self.img:getWidth()
	local h = self.img:getHeight()
	
	local draw_x = coords[1] + self.x*canvas:getWidth()/2
	local draw_y = coords[2] + self.y*canvas:getHeight()/2
	
	if not smooth then
		draw_x = math.floor(draw_x)
		draw_y = math.floor(draw_y)
	end
	
	g.draw(self.img, draw_x, draw_y, 0, scale, scale, w/2, h/2)
end

function getScreenCoords(canvas, offset_x, offset_y, z)
	local screenx = (1 + z*offset_x) / 2
	local screeny = (1 + z*offset_y) / 2
	
	return {screenx * love.graphics.getWidth(), screeny * love.graphics.getHeight()}
end

return Sprite