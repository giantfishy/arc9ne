-- MENU.LUA - for drawing the menus and taking user input

local Menu = {}
Menu.__index = Menu

function Menu.new()
	local self = setmetatable({}, Menu)
	
	self.items = {"start", "continue", "options", "characters", "about", "exit"}
	self.selected = 1
	
	self.y = 1
	
	self.bg = love.graphics.newImage("assets/bg/menu_start.png")
	
	return self
end

function Menu.draw(self)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	
	love.graphics.push()
	local parallax = 0.01
	local maxY = #self.items * h * parallax
	local scale = (h + maxY) / self.bg:getHeight()
	love.graphics.translate(0, self.y * h * -parallax)
	love.graphics.draw(self.bg, 0, 0, 0, scale, scale)
	love.graphics.pop()
	
	local bandWidth = h*0.12
	love.graphics.setColor(255, 255, 255, 100)
	love.graphics.rectangle("fill", 0, (h-bandWidth)*0.5, w, bandWidth)
	
	love.graphics.setColor(255, 255, 255)
	setFont("title")
	drawText("ARC9NE", w*0.9, h*0.5, "right")
	
	love.graphics.push()
	love.graphics.translate(0, self.y * h * -0.05)
	
	for i=1, #self.items do
		local y = 0.5 + (i * 0.05)
		if i < self.selected then
			y = y - 0.05
		elseif i > self.selected then
			y = y + 0.05
		end
		if self.items[i] == "continue" and not love.filesystem.exists("progress.txt") then
			love.graphics.setColor(255, 255, 255, 100)
		else
			love.graphics.setColor(255, 255, 255)
		end
		if i == self.selected then setFont("selected") else setFont("menuItem") end
		drawText(self.items[i], w*0.4, h*y, "right")
	end
	love.graphics.pop()
end

function drawText(text, x, y, align)
	local width = love.graphics.getFont():getWidth(text)
	local height = love.graphics.getFont():getAscent()
	
	if align == "right" then
		x = x - width
	elseif align == "center" then
		x = x - width/2
	end
	love.graphics.printf(text, math.floor(x), math.floor(y - height/2 - 8), love.graphics.getWidth(), "left")
end

function Menu.update(self, dt)
	local diff = self.selected - self.y
	local ease = 0.4
	self.y = self.y + diff*ease
end

function Menu.keypressed(self, key)
	if key == "space" or key == "return" or key == "kpenter" then
		local item = self.items[self.selected]
		if item == "start" then
			changeState("comic")
			loadScene("act1/scene1")
		elseif item == "exit" then
			love.event.quit()
		end
	else
		if key == "up" then
			self.selected = self.selected - 1
			if self.selected < 1 then self.selected = 1 end
		elseif key == "down" then
			self.selected = self.selected + 1
			if self.selected > #self.items then self.selected = #self.items end
		end
	end
end

return Menu