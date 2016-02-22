-- SCENE.LUA - class for loading images and keyframes from a file, and displaying them accordingly

local Keyframe = require('keyframe')
local Keyframer = require('keyframer')
local Sprite = require('sprite')
local Commands = require('commands')

local Scene = {}
Scene.__index = Scene

local g = love.graphics
local basedir = love.filesystem.getSourceBaseDirectory().."/arc9ne/"

function Scene.new(filename)
	local self = setmetatable({}, Scene)
	self.images = {}
	self.sprites = {}
	self.keyframes = {}
	self.cameraKeyframes = {}
	self.keyframers = {} -- eugh
	
	self.time = 0
	self.keyframe = 0
	self.paused = false
	
	self.cam_x = 0
	self.cam_y = 0
	
	self:loadScene(basedir.."story/"..filename..".txt")
	
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
	g.translate(-(love.graphics.getWidth() - canvas:getWidth())/2, -(love.graphics.getHeight() - canvas:getHeight())/2)
	
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
	
	-- for some reason i need this line or it won't clear the sprites. what's going on
	drawText(#spr, -50, -50, "left")
	
	g.pop()
	g.setCanvas()
end

function Scene.update(self, dt)
	if self.paused == false then self.time = self.time + dt end
	
	for name, sprite in pairs(self.sprites) do
		if sprite.keyframer ~= nil then sprite.keyframer:update(self.time) end
	end
	
	local currentKey = nil
	local nextKey = nil
	for i=1,#self.cameraKeyframes do
		if self.cameraKeyframes[i].t > self.time then
			currentKey = self.cameraKeyframes[i-1]
			nextKey = self.cameraKeyframes[i]
			break
		end
	end
	
	if nextKey ~= nil then
		if currentKey == nil then currentKey = {t=0, x=nextKey.x, y=nextKey.y} end -- if there's no keyframe at t=0
		
		local panTime = (nextKey.t - currentKey.t) -- time taken to move the camera
		local percent = 1 - ((nextKey.t - self.time) / panTime)
		self.cam_x = currentKey.x + percent*(nextKey.x - currentKey.x)
		self.cam_y = currentKey.y + percent*(nextKey.y - currentKey.y)
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
					if startsWith(line, "camera ") then
						-- add key to cameraKeyframes
						local coords = splitStr(line)
						local camkey = {}
						
						camkey.t = self.keyframes[#self.keyframes].t
						camkey.x = tonumber(coords[2])
						camkey.y = tonumber(coords[3])
						self.cameraKeyframes[#self.cameraKeyframes+1] = camkey
					elseif startsWith(line, "key ") then
						local args = splitStr(line:sub(5))
						local name = args[1]
						local style = args[5]
						if style == nil then style = "linear" end
						
						local values = {}
						values.x = args[2]
						values.y = args[3]
						values.z = args[4]
						
						local keyframer = self.keyframers[name]
						if keyframer == nil then
							keyframer = Keyframer.new(nil)
							self.keyframers[name] = keyframer
							print("Added keyframer to sprite \""..name.."\"")
						end
						keyframer:add(key.t, style, values)
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