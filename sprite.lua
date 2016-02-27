-- SPRITE.LUA - an image with a location in (pseudo)3D space. knows how to draw itself

local Sprite = {}
Sprite.__index = Sprite

local g = love.graphics

function Sprite.new(img, x, y, z, dimx, dimy)
	local self = setmetatable({}, Sprite)
	self.img = img
	self.x = x
	self.y = y
	self.z = z
	self.scale = 1
	self.color = "#FFFFFF"
	self.alpha = 255
	
	self.dimx = dimx
	self.dimy = dimy
	self.frame = 0
	self.animate = 0
	
	self.keyframer = nil
	
	return self
end

function Sprite.draw(self, canvas, offset_x, offset_y, smooth, scale)
	if self.alpha == 0 then return end
	if scale == nil then scale = 1 end
	local coords = getScreenCoords(canvas, offset_x, offset_y, self.z)
	local w = self.img:getWidth()
	local h = self.img:getHeight()
	
	scale = self.scale * scale
	
	local draw_x = coords[1] + self.x*canvas:getWidth()/2
	local draw_y = coords[2] + self.y*canvas:getHeight()/2
	
	if not smooth then
		draw_x = math.floor(draw_x)
		draw_y = math.floor(draw_y)
	end
	
	g.push("all")
	local c = {255, 255, 255}
	if self.color ~= "#FFFFFF" then
		c = parseHex(self.color)
	end
	g.setColor(c[1], c[2], c[3], self.alpha)
	
	if self.dimx == 1 and self.dimy == 1 then -- not a spritesheet
		g.draw(self.img, draw_x, draw_y, 0, scale, scale, w/2, h/2)
	else
		local fr = math.floor(self.frame)
		
		local qw = (self.img:getWidth()/self.dimx)
		local qh = (self.img:getHeight()/self.dimy)
		local qx = (fr % self.dimx) * qw
		local qy = math.floor(fr / self.dimx) * qh
		local quad = g.newQuad(qx, qy, qw, qh, w, h)
		
		g.draw(self.img, quad, draw_x, draw_y, 0, scale, scale, qw/2, qh/2)
	end
	g.pop()
end

function Sprite.update(self, dt)
	if self.animate ~= 0 then
		local interval = 1 / self.animate -- amount of time, in seconds, between frames
		
		self.frame = self.frame + dt/interval
		if self.frame >= self.dimx*self.dimy then
			self.frame = self.frame - self.dimx*self.dimy
		end
	end
end

function Sprite.move(self, x, y, z)
	self.x = x
	self.y = y
	self.z = z
end

function getScreenCoords(canvas, offset_x, offset_y, z)
	local screenx = (1 + z*offset_x) / 2
	local screeny = (1 + z*offset_y) / 2
	
	return {screenx * canvas:getWidth(), screeny * canvas:getHeight()}
end

return Sprite