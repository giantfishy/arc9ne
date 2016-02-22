-- CHARSELECT.LUA - for drawing (and handling user input for) the character select screen

local Charselect = {}
Charselect.__index = Charselect

local g = love.graphics

local acts = {}
acts[1] = {"noah", "izzy", "cleo"}
acts[2] = {"diana", "mark", "liam"}
acts[3] = {"hana", "olly", "alex"}
acts[4] = {"felix", "petra", "scott"}

local color = {"087756", "788CFF", "B43CF0", "FFA03C"}

function Charselect.new()
	local self = setmetatable({}, Charselect)
	
	self.x = 1
	self.y = 1
	
	self.scale = {}
	for x=1,#acts do
		self.scale[x] = {}
		for y=1,#acts[x] do
			self.scale[x][y] = 0
		end
	end
	
	self.img = {}
	for actnum, chars in ipairs(acts) do
		for i, c in ipairs(chars) do
			self.img[chars[i]] = love.graphics.newImage("assets/char_icons/"..c..".tga")
		end
	end
	
	return self
end

function Charselect.draw(self)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	local name = acts[self.x][self.y]
	
	local c = parseHex(color[self.x])
	if not unlocked(self.x, name) then c = {60, 60, 60} end
	g.setBackgroundColor(lerpColor(c, {0, 0, 0}, 0.5))
	
	local incr = 0.1
	for y = 0, h, incr do
		g.setColor(lerpColor(c, {0, 0, 0}, 0.3 + y*0.4))
		g.rectangle("fill", 0, y*h, w, h*incr)
	end
	g.setColor(255, 255, 255)
	
	setFont("selected")
	drawText("chapter select", 25, h*incr/2, "left")
	setFont("small")
	drawText("chapters within an act can be read in any order", w-25, h*(1-incr/2), "right")
	
	g.push()
	local tile = 128
	if w < 800 then tile = 100 end
	g.translate((w - tile * #acts)/2, 30+(h - tile * #acts[1])/2)
	
	setFont("small")
	if not unlocked(self.x, name) then name = "???" end
	drawText(name, (self.x-0.5)*tile, #acts[1]*tile + 20, "center")
	for x=1,#acts do
		drawText("ACT "..x, (x-0.5)*tile, -20, "center")
		
		local mult = 0.8
		g.setColor(c)
		if x ~= self.x then g.setColor(lerpColor(c, {255, 255, 255}, 0.5)) end
		for i=1, #acts[x] do
			g.ellipse("fill", (x-0.5)*tile, (i-0.5)*tile, tile*mult/2, tile*mult/2)
			if i > 1 then
				g.rectangle("fill", (x-1+(1-mult)/2)*tile, (i-1.5)*tile, tile*mult, tile)
			end
		end
		
		for y=1,#acts[x] do
			local img = self.img[acts[x][y]]
			local alpha = 255
			if self.x == x then
				if self.y ~= y then alpha = 160 end
			else
				alpha = 80
			end
			
			local scale = mult
			if self.x == x and self.y == y then scale = 1 end
			self.scale[x][y] = self.scale[x][y] + 0.5*(scale-self.scale[x][y])
			
			g.setColor(255, 255, 255, alpha)
			if not unlocked(x, acts[x][y]) then g.setColor(0, 0, 0, alpha) end
			g.draw(img, (x-0.5)*tile, (y-0.5)*tile, 0, self.scale[x][y], self.scale[x][y], 64, 64)
			g.setColor(255, 255, 255)
		end
	end
	g.pop()
end

function Charselect.update(dt)
	
end

function Charselect.keypressed(self, key)
	if key == "escape" then
		changeState("menu")
	elseif key == "space" or key == "return" or key == "kpenter" then
		local filename = acts[self.x][self.y].."/scene1"
		if sceneExists(acts[self.x][self.y].."/scene1") then
			changeState("comic")
			loadScene(filename)
		else
			print(filename..".txt does not exist!")
		end
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

function unlocked(actnum, name)
	if actnum > 1 then return false end
	return true
end

return Charselect