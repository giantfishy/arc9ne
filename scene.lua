-- SCENE.LUA - class for loading images and keyframes from a file, and displaying them accordingly

local Keyframe = require('keyframe')
local Keyframer = require('keyframer')
local Sprite = require('sprite')
local Commands = require('commands')

local Scene = {}
Scene.__index = Scene

local g = love.graphics

function Scene.new(filename)
	local self = setmetatable({}, Scene)
	self.images = {}
	self.audio = {}
	self.sprites = {}
	self.keyframes = {}
	
	self.keyframers = {} -- eugh
	self.keyframer = Keyframer.new(self)
	
	self.time = -0.1
	self.keyframe = 0
	self.paused = false
	self.text = nil
	
	self.cam_x = 0
	self.cam_y = 0
	
	self:loadScene("story/"..filename..".txt")
	
	return self
end

function Scene.draw(self, canvas, eyeoffset, smooth)
	if self.keyframe == 0 then return end
	if eyeoffset == nil then eyeoffset = 0 end
	if smooth == nil then smooth = true end
	
	local scale = canvas:getWidth() / 1600 -- 1600x1200 is highest resolution
	
	g.setCanvas(canvas)
	g.clear()
	g.push()
	
	local spr = {}
	for name, sprite in pairs(self.sprites) do
		spr[#spr+1] = sprite
	end
	
	-- reorder the array in order of z value
	local sortFunction = function(a, b)
		-- not entirely sure why the tonumber() needs to be there but it does apparently
		return tonumber(a.z) < tonumber(b.z)
	end
	table.sort(spr, sortFunction)
	
	for i, sprite in ipairs(spr) do
		sprite:draw(canvas, -self.cam_x + eyeoffset, -self.cam_y, smooth, scale)
	end
	
	if self.text ~= nil then
		local h = g.getHeight() * 0.2
		local x = h/2
		local y = g.getHeight() - h * (1 - self.text.ease)
		
		g.setColor(255, 255, 255, 150)
		g.rectangle("fill", 0, y, g.getWidth(), h)
		
		if self.text.ch ~= "" then
			x = h
			local img = allStates.charselect.img[self.text.ch]
			local scale = 1
			if h < 128 then scale = h / 128 end
			g.setColor(255, 255, 255)
			g.draw(img, x/2, y + h/2, 0, scale, scale, 64, 64)
		end
		
		g.setColor(0, 0, 0)
		setFont("selected")
		drawText(self.text.ch:upper()..":", x, y + h/4, "left")
		setFont("menuItem")
		drawText(self.text.msg, x, y + h/2, "left")
		g.setColor(255, 255, 255)
	end
	
	-- for some reason i need this line or it won't clear the sprites. what's going on
	drawText(#spr, -50, -50, "left")
	
	g.pop()
	g.setCanvas()
end

function Scene.update(self, dt)
	if not self.paused then
		self.time = self.time + dt
	end
	
	-- update keyframers
	self.keyframer:update(self.time)
	for name, sprite in pairs(self.sprites) do
		sprite:update(dt)
		if sprite.keyframer ~= nil then sprite.keyframer:update(self.time) end
	end
	
	if self.text ~= nil then
		self.text.ease = self.text.ease * 0.6
		
		if not self.paused then
			self.text.t = self.text.t - dt
			if self.text.t <= 0 then
				self.text = nil
			end
		end
	end
	
	nextKey = self:getNextKeyframe()
	if nextKey ~= nil then
		if self.time > nextKey.t then
			self.keyframe = self.keyframe + 1
			print("== #"..nextKey.t.." ==")
			self:doKeyframe(nextKey.commands)
			print("")
		end
	else
		return true -- finished
	end
	return false -- not finished
end

function Scene.getNextKeyframe(self)
	return self.keyframes[self.keyframe+1]
end

function Scene.loadScene(self, filename)
	print("Reading scene file \""..filename.."\"...\n")
	if not love.filesystem.isFile(filename) then
		print("File \""..filename.."\" does not exist!")
		return
	end
	
	local loadingAssets = true
	local dir = ""
	
	for line in love.filesystem.lines(filename) do
		line = line:gsub("\r\n?", "")
		if line:len() == 0 then
			loadingAssets = false
			print()
		end
		
		if loadingAssets then
			if startsWith(line, "/") then
				dir = line:sub(2).."/"
			else
				if line:find(".ogg") == nil then -- it's an image
					local split = line:find("|")
					if split == nil then
						self:loadImage(dir..line)
					else
						local data = splitStr(line:sub(split+1), "x")
						line = line:sub(1, split-1)
						self:loadImage(dir..line, data[1], data[2], data[3])
					end
					
					local keyframer = Keyframer.new(nil)
					self.keyframers[line] = keyframer
				else -- it's a sound file
					self:loadAudio(dir..line)
				end
			end
		else
			if startsWith(line, "#") then -- this line is the start of a keyframe definition
				local prev = self.keyframes[#self.keyframes]
				local key = Keyframe.new(tonumber(line:sub(2)), prev)
				self.keyframes[#self.keyframes + 1] = key
			elseif line:len() ~= 0 then
				local key = self.keyframes[#self.keyframes]
				if key ~= nil then
					key:addCommand(line)
					if startsWith(line, "camera ") then
						line = line:gsub("camera ", "")
						local data = parseKeyframer(splitStr(line))
						
						self.keyframer:add(key.t, data[1], data[2])
					elseif startsWith(line, "key ") then
						line = line:gsub("key ", "")
						local args = splitStr(line)
						local name = args[1]
						line = line:gsub(name.." ", "")
						
						local keyframer = self.keyframers[name]
						local data = parseKeyframer(splitStr(line))
						keyframer:add(key.t, data[1], data[2])
					end
					print("Command \""..line.."\" added at "..key.t.." seconds!")
				else
					print("No keys yet, cannot add command \""..line.."\"!")
				end
			end
		end
	end
	print("\nFinished reading scene file \""..filename.."\"!\n")
end

function parseKeyframer(args)
	local style = "linear" -- default value
	local values = {}
	for i, arg in ipairs(args) do
		if arg:find("=") == nil then -- not a variable but (hopefully!) the easing style
			style = arg
		else
			local data = splitStr(arg, "=")
			values[data[1]] = data[2]
		end
	end
	
	return {style, values}
end

function Scene.loadImage(self, imagename, dimx, dimy, anim)
	local filename = "assets/"..imagename
	local img = nil
	for i, extension in ipairs({".png", ".tga"}) do
		if love.filesystem.isFile(filename..extension) then
			img = g.newImage(filename..extension)
			break
		end
	end
	if img == nil then
		print("Could not find file \""..imagename.."\"")
		return
	end
	if dimx == nil then dimx = 1 end
	if dimy == nil then dimy = 1 end
	
	local key = imagename -- where to put the image in self.images
	while key:find("/") ~= nil do
		key = key:sub(key:find("/") + 1)
	end
	if self.images[key] ~= nil then
		local num = 2
		while self.images[key..num] ~= nil do num = num + 1 end
		key = key..num
	end
	
	local data = {}
	data.img = img
	data.dimx = dimx
	data.dimy = dimy
	data.animate = anim
	
	self.images[key] = data
	
	local brackets = " ("..dimx.."x"..dimy..")"
	if dimx == 1 and dimy == 1 then brackets = "" end
	print("Loaded image "..imagename..".png as '"..key.."'"..brackets)
end

function Scene.loadAudio(self, filename)
	local src = love.audio.newSource(filename)
	local path = splitStr(filename:gsub(".ogg", ""), "/")
	if src ~= nil then
		self.audio[path[#path]] = src
		print("Loaded audio \""..path[#path].."\"")
	else
		print("Could not find \""..filename.."\"")
	end
end

function Scene.playAudio(self, name)
	local src = self.audio[name]
	if src == nil then
		print("Could not play audio file \""..name.."\"")
		return
	end
	src:play()
	print("Started playing audio file \""..name.."\"")
end

function Scene.doKeyframe(self, commands)
	for i, c in ipairs(commands) do		
		local tokens = splitStr(c)
		if c == nil then
			print("Command \""..c.."\" failed to parse!")
		elseif c ~= "" then
			Commands.parse(self, c)
		end
	end
end

return Scene