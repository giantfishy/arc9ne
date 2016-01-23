-- CHARSELECT.LUA - for drawing (and handling user input for) the character select screen

local Charselect = {}
Charselect.__index = Charselect

local g = love.graphics

local acts = {}
acts[1] = {"noah", "izzy", "cleo"}
acts[2] = {"diana", "mark", "liam"}
acts[3] = {"hana", "olly", "alex"}
acts[4] = {"felix", "petra", "scott"}

function Charselect.new()
	local self = setmetatable({}, Charselect)
	
	self.x = 1
	self.y = 1
	
	self.img = {}
	for actnum, chars in ipairs(acts) do
		for i, c in ipairs(chars) do
			if actnum > 1 then -- or if the character is locked
				c = "locked"
			end
			self.img[chars[i]] = love.graphics.newImage("assets/char_icons/"..c..".png")
		end
	end
	
	return self
end

function Charselect.draw(self)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	
	g.push()
	local tile = 130
	g.translate((w - tile * #acts)/2, (h - tile * #acts[1])/2)
	
	g.setColor(255, 255, 255, 100)
	g.ellipse("fill", (self.x-0.5)*tile, (self.y-0.5)*tile, tile/2, tile/2)
	g.setColor(255, 255, 255)
	
	setFont("small")
	drawText(acts[self.x][self.y], (self.x-0.5)*tile, #acts[1]*tile + 20, "center")
	for x=1,#acts do
		drawText("ACT "..x, (x-0.5)*tile, -20, "center")
		for y=1,#acts[x] do
			local img = self.img[acts[x][y]]
			local padding = (tile - 128) / 2
			g.draw(img, (x-1)*tile + padding, (y-1)*tile + padding)
		end
	end
	g.pop()
end

function Charselect.update(dt)
	
end

function Charselect.keypressed(self, key)
	if key == "escape" then
		changeState("menu")
	elseif key == "left" and self.x > 1 then
		self.x = self.x - 1
	elseif key == "right" and self.x < #acts then
		self.x = self.x + 1
	elseif key == "up" and self.y > 1 then
		self.y = self.y - 1
	elseif key == "down" and self.y < #acts[1] then
		self.y = self.y + 1
	end
end

return Charselect