-- MENU.LUA - for drawing the menus and taking user input

local Menu = {}
Menu.__index = Menu

function Menu.new()
	local self = setmetatable({}, Menu)
	
	self.items = {"start", "continue", "options", "cast", "about", "exit"}
	self.selected = 1
	
	return self
end

function Menu.draw(self)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	
	local bandWidth = h*0.12
	love.graphics.setColor(255, 255, 255, 100)
	love.graphics.rectangle("fill", 0, (h-bandWidth)*0.5, w, bandWidth)
	
	love.graphics.setColor(255, 255, 255)
	setFont("title")
	drawText("ARC9NE", w*0.9, h*0.5, "right")
	setFont("selected")
	drawText(self.items[self.selected], w*0.3, h*0.5, "right")
	
	setFont("menuItem")
	for i=1, #self.items do
		if i ~= self.selected then
			local y = 0.5 + ((i - self.selected) * 0.05)
			if i < self.selected then
				y = y - 0.05
			else
				y = y + 0.05
			end
			drawText(self.items[i], w*0.3, h*y, "right")
		end
	end
end

function drawText(text, x, y, align)
	local width = love.graphics.getFont():getWidth(text)
	local height = love.graphics.getFont():getAscent()
	
	if align == "right" then
		x = x - width
	elseif align == "center" then
		x = x - width/2
	end
	love.graphics.printf(text, x, y - height/2 - 8, love.graphics.getWidth(), "left")
end

function Menu.update(self, dt)
	
end

function Menu.keypressed(self, key)
	if key == "space" then
		changeState("comic")
		loadScene("act1/scene1")
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