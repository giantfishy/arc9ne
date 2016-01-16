local Keyframe = require('keyframe')
local Sprite = require('sprite')

local Scene = {}
Scene.__index = Scene

local g = love.graphics
local basedir = love.filesystem.getSourceBaseDirectory().."/arc9ne/"

function Scene.new(filename)
	local self = setmetatable({}, Scene)
	self.images = {}
	self.sprites = {}
	self.keyframes = {}
	
	self.time = 0
	self.keyframe = 0
	self.paused = false
	
	self.cam_x = 0
	self.cam_y = 0
	
	self:loadScene(basedir.."story/"..filename..".txt")
	
	return self
end

function Scene.draw(self, canvas, eyeoffset)
	if self.keyframe == 0 then return end
	if eyeoffset == nil then eyeoffset = 0 end
	
	g.setCanvas(canvas)
	g.clear()
	g.push()
	g.translate(-(love.graphics.getWidth() - canvas:getWidth())/2, -(love.graphics.getHeight() - canvas:getHeight())/2)
	
	local cx = self.cam_x
	local cy = self.cam_y
	local nextKey = self:getNextKeyframe()
	if nextKey ~= nil then
		local panTime = (nextKey.t - self.keyframes[self.keyframe].t)
		local percent = 1 - ((nextKey.t - self.time) / panTime)
		cx = self.cam_x + percent*(nextKey.cam_x - self.cam_x)
		cy = self.cam_y + percent*(nextKey.cam_y - self.cam_y)
	end
	
	for i, sprite in ipairs(self.sprites) do
		sprite:draw(cx+eyeoffset, cy)
	end
	
	g.pop()
	g.setCanvas()
end

function Scene.update(self, dt)
	if self.paused == false then self.time = self.time + dt end
	
	local nextKey = self:getNextKeyframe()
	if nextKey ~= nil then
		if self.time > nextKey.t then
			self.keyframe = self.keyframe + 1
			self:doKeyframe(nextKey.commands)
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
	if io.open(filename) == nil then
		print("File \""..filename.."\" does not exist!")
		return
	end
	
	local loadingAssets = true
	local dir = ""
	
	for line in io.lines(filename) do
		if line:len() == 0 then
			loadingAssets = false
			print()
		end
		
		if loadingAssets then
			if startsWith(line, "/") then
				dir = line:sub(2).."/"
			else
				self:loadImage(dir..line)
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
					print("Command \""..line.."\" added to key at "..key.t.." seconds!")
				else
					print("No keys yet, cannot add command \""..line.."\"!")
				end
			end
		end
	end
	print("\nFinished reading scene file \""..filename.."\"!\n")
end

function Scene.loadImage(self, imagename)
	local img = g.newImage("assets/"..imagename..".png")
	
	local key = imagename -- where to put the image in self.images
	if key:find("/") ~= nil then
		key = key:sub(key:find("/") + 1)
	end
	if self.images[key] ~= nil then
		local num = 2
		while self.images[key..num] ~= nil do num = num + 1 end
		key = key..num
	end
	
	self.images[key] = img
	
	print("Loaded image "..imagename..".png as '"..key.."'")
end

function Scene.doKeyframe(self, commands)
	-- clean this garbage up later
	
	print("Executing keyframe...\n")
	for i, c in ipairs(commands) do
		--print("  "..c)
		
		--[[
		TODO:
		- make a table of accepted commands, with how many additional tokens each command expects
		  e.g. self.commands["place"] = 4
		- make a class which has a function for each command
		- make it call the command on that class, with _G, somehow? figure that out?
		- alternatively i think Commands[ tokens[1] ]() or similar could work
		]]--
		
		local tokens = splitStr(c)
		if tokens == nil or #tokens == 0 then
			print("Command \""..c.."\" failed to parse!")
		else
			if tokens[1] == "place" and #tokens == 5 then
				self.sprites[#self.sprites+1] = Sprite.new(self.images[tokens[2]], tonumber(tokens[3]), tonumber(tokens[4]), tonumber(tokens[5]))
				print("Placed sprite \""..tokens[2].."\" at "..tokens[3]..", "..tokens[4]..", "..tokens[5])
			elseif tokens[1] == "camera" and #tokens == 3 then
				self.cam_x = tonumber(tokens[2])
				self.cam_y = tonumber(tokens[3])
				print("Moved camera to "..tokens[2]..", "..tokens[3])
			elseif tokens[1] == "load" and #tokens == 2 then
				self = Scene.new(tokens[2])
			elseif tokens[1] == "pause" and #tokens == 1 then
				self.paused = true
			end
		end
	end
	
	-- reorder the self.sprites array in order of parallax
	local sortFunction = function(a, b)
		return a.parallax < b.parallax
	end
	table.sort(self.sprites, sortFunction)
	
	print("\nFinished executing keyframe.")
end

function startsWith(str, start)
	return (str:sub(1, start:len()) == start)
end

function splitStr(str)
	local tokens = {}
	local index = 1
	local previndex = 1
	while index ~= nil do
		index = str:find(" ", index)
		if index == nil then
			tokens[#tokens+1] = str:sub(previndex)
			break
		end
		tokens[#tokens+1] = str:sub(previndex, index-1)
		index = index + 1
		previndex = index
	end
	return tokens
end

return Scene