-- MENU.LUA - for drawing the menus and taking user input

local Options = require('states/options')

local Menu = {}
Menu.__index = Menu

function Menu.new()
	local self = setmetatable({}, Menu)
	
	self.items = {"start", "continue", "options", "characters", "about", "exit"}
	self.selected = 1
	
	self.y = 1
	
	self.menu = "main"
	self.options = Options.new(self)
	
	self.about = ""
	for line in io.lines(love.filesystem.getSourceBaseDirectory().."/arc9ne/about.txt") do
		self.about = self.about.."\n"..line
	end
	self.abouty = 0
	
	self.bg = love.graphics.newImage("assets/bg/menu_start.png")
	
	return self
end

function Menu.draw(self)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	
	local bgHeight = h * 1.2 -- height * 1.2 so the background is slightly larger than the window
	local scale = bgHeight / self.bg:getHeight()
	local itemNum = #self.items
	if self.menu == "options" then itemNum = #self.options.items end
	local parallax = (bgHeight - h) / itemNum
	love.graphics.draw(self.bg, 0, (self.y-1) * -parallax, 0, scale, scale)
	
	local bandWidth = h*0.12
	love.graphics.setColor(255, 255, 255, 100)
	if self.menu ~= "about" then
		love.graphics.rectangle("fill", 0, (h-bandWidth)*0.5, w, bandWidth)
	end
	
	if self.menu == "main" then
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
	elseif self.menu == "options" then
		love.graphics.setColor(255, 255, 255)
		self.options:draw()
	elseif self.menu == "about" then
		setFont("small")
		love.graphics.setColor(0, 0, 0, 100)
		love.graphics.rectangle("fill", w*0.1 - 20, 0, w*0.8 + 40, h)
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf(self.about, w*0.1, h*0.2 - self.abouty, w*0.8, "left")
	end
end

function Menu.update(self, dt)
	local diff = self.selected - self.y
	local ease = 0.4
	self.y = self.y + diff*ease
	
	if self.menu == "about" then
		local font = love.graphics.getFont()
		local w, wrappedtext = font:getWrap(self.about, love.graphics.getWidth()*0.8)
		local h = (font:getHeight() * #wrappedtext) - love.graphics.getHeight()*0.6
		if h < 0 then h = 0 end
		local speed = 8
		if love.keyboard.isDown("up") then
			self.abouty = self.abouty - speed
			if self.abouty < 0 then self.abouty = 0 end
		elseif love.keyboard.isDown("down") then
			self.abouty = self.abouty + speed
			if self.abouty > h then self.abouty = h end
		end
	end
end

function Menu.keypressed(self, key)
	if self.menu == "main" then
		if key == "space" or key == "return" or key == "kpenter" then
			local item = self.items[self.selected]
			if item == "start" then
				changeState("charselect")
				--loadScene("act1/scene1")
			elseif item == "options" then
				self.options = Options.new(self)
				self.menu = "options"
				self.selected = 1
			elseif item == "about" then
				self.menu = "about"
				self.abouty = 0
			elseif item == "exit" then
				love.event.quit()
			end
		else
			if key == "up" then
				self.selected = self.selected - 1
				if self.selected < 1 then self.selected = #self.items end
			elseif key == "down" then
				self.selected = self.selected + 1
				if self.selected > #self.items then self.selected = 1 end
			end
		end
	elseif self.menu == "options" then
		if key == "escape" then
			love.audio.setVolume(getSettings().volume)
			self.menu = "main"
			self.selected = 3
		elseif key == "space" or key == "return" or key == "kpenter" then
			local newOptions = self.options.options
			local resize = false
			if newOptions.resolution ~= getSettings().resolution or newOptions.fullscreen ~= getSettings().fullscreen then
				resize = true
			end
			
			setSettings(newOptions)
			if resize then resizeWindow() end
			if newOptions.volume == 0 then
				love.audio.pause()
				love.audio.rewind()
			end
			self.menu = "main"
			self.selected = 3
		elseif key == "up" then
			self.selected = self.selected - 1
			if self.selected < 1 then self.selected = #self.options.items end
		elseif key == "down" then
			self.selected = self.selected + 1
			if self.selected > #self.options.items then self.selected = 1 end
		elseif key == "right" then
			self.options:increment(1)
		elseif key == "left" then
			self.options:increment(-1)
		elseif key == "r" then
			local reset = love.window.showMessageBox("reset settings", "are you sure you want to reset the settings to their default values?", {"yes", "no"})
			if reset == 2 then
				resetSettings()
				self.options:updateSettings()
			end
		end
	elseif self.menu == "about" then
		if key == "escape" or key == "space" or key == "return" or key == "kpenter" then
			self.menu = "main"
		end
	end
end

return Menu