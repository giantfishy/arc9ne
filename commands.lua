-- COMMANDS.LUA - for parsing commands in the .txt files which make up the keyframe instructions

local Sprite = require('sprite')

local Commands = {}

Commands.parse = function(parent, text)
	local tokens = splitStr(text)
	
	local functionName = tokens[1]
	local t = Commands[functionName] -- table containing the number of expected arguments and the function itself
	
	if t == nil then
		print("No command \""..functionName.."\"")
		return
	end
	
	local args = {}
	for i=2, #tokens do
		args[i-1] = tokens[i]
	end
	
	local expectedArgs = t[1]
	local func = t[2]
	
	-- if expectedArgs is nil, it can take any number of arguments
	if expectedArgs == nil then expectedArgs = #args end
	
	if func == nil or expectedArgs == nil then
		print("No command \""..functionName.."\"")
		return
	end
	if expectedArgs ~= #args then
		print("Incorrect number of arguments for \""..functionName.."\" command (expected "..expectedArgs..", recieved "..#args..")")
		return
	end
	
	if #args == 0 then
		func(parent)
	else
		func(parent, args)
	end
end

-- commands:
-- (first element of table is the number of expected arguments, second element is the function)

Commands.place = {4, function(parent, args)
	local img = args[1]
	local x = tonumber(args[2])
	local y = tonumber(args[3])
	local z = tonumber(args[4])
	
	if parent.images[img] == nil then
		print("Could not place image \""..img.."\"")
		return
	end
	
	local data = parent.images[img]
	local sprite = Sprite.new(data.img, x, y, z, data.dimx, data.dimy)
	if data.animate ~= nil then sprite.animate = data.animate end
	local id = img
	if parent.sprites[img] ~= nil then
		local num = 2
		while parent.sprites[img..num] ~= nil do
			num = num + 1
		end
		id = img..num
	end
	
	local keyframer = parent.keyframers[id]
	if keyframer ~= nil then
		keyframer.parent = sprite
		
		local values = {}
		for key, value in pairs(sprite) do
			if key ~= "keyframer" then
				values[key] = value
			end
		end
		keyframer:add(0, "instant", values)
		
		sprite.keyframer = keyframer
	end
	
	parent.sprites[id] = sprite
	print("Placed sprite \""..id.."\" at "..x..", "..y..", "..z)
end}

Commands.camera = {nil, function(parent, args)
	local x = nil
	local y = nil
	for i, arg in ipairs(args) do
		if arg:find("=") ~= nil then
			local data = splitStr(arg, "=")
			if data[1] == "cam_x" then
				x = data[2]
			elseif data[1] == "cam_y" then
				y = data[2]
			end
		end
	end
	
	if x == nil then x = parent.cam_x end
	if y == nil then y = parent.cam_y end
	
	parent.cam_x = x
	parent.cam_y = y
	print("Moved camera to "..x..", "..y)
end}

Commands.load = {1, function(parent, args)
	local scene = args[1]
	loadScene(scene)
	love.audio.stop()
	print("Loaded scene "..args[1])
end}

Commands.pause = {0, function(parent, args)
	parent.paused = true
	print("Paused")
end}

Commands.play = {1, function(parent, args)
	parent:playAudio(args[1])
end}

Commands.clear = {0, function(parent, args)
	parent.sprites = {}
	print("Cleared sprites")
end}

Commands.remove = {1, function(parent, args)
	parent.sprites[args[1]] = nil
	print("Removed sprite \""..args[1].."\"")
end}

Commands.replace = {2, function(parent, args)
	local sprite = parent.sprites[args[1]]
	local img = parent.images[args[2]]
	
	for key, value in pairs(img) do
		sprite[key] = value
	end
	print("Replaced sprite \""..args[1].."\" with \""..args[2].."\"")
end}

Commands.text = {nil, function(parent, args)
	local character = ""
	local t = 0
	local msg = ""
	
	local start = 1
	
	if #args >= 3 then
		-- this is a bit awful i'm sorry
		if args[1] == "nil" or love.filesystem.isFile("assets/char_icons/"..args[1]..".tga") then
			character = args[1]
			start = 2
			
			if tonumber(args[2]) ~= nil then
				t = tonumber(args[2])
				start = 3
			end
		end
	end
	
	for i = start, #args do
		msg = msg..args[i]:gsub("|", "\n").." " -- replace "|" with a newline
	end
	
	if character == "nil" then character = "" end -- in case a narrative dialogue prompt needs to start with a character name
	
	print(character:upper()..": "..msg)
	
	local data = {}
	data.ch = character
	data.t = t
	data.msg = msg
	data.ease = 1
	
	parent:addPrompt(data)
end}

Commands.key = {nil, function(parent, args)
	local sprite = parent.sprites[args[1]]
	local values = {}
	for i, arg in ipairs(args) do
		if arg:find("=") ~= nil then
			local data = splitStr(arg, "=")
			values[data[1]] = data[2]
		end
	end
	
	local msg = "Set values of sprite \""..args[1].."\":"
	local changedValues = false
	for key, value in pairs(values) do
		if value ~= nil then sprite[key] = value end
		
		msg = msg.." "..key.." = "..value..";"
		changedValues = true
	end
	
	if changedValues then
		print(msg:sub(1, msg:len()-1))
	end
end}

return Commands