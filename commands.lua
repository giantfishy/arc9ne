-- COMMANDS.LUA - for parsing commands in the .txt files which make up the keyframe instructions

local Sprite = require('sprite')

local Commands = {}

Commands.parse = function(parent, text)
	local tokens = splitStr(text)
	
	local functionName = tokens[1]
	local t = Commands[functionName] -- table containing the number of expected arguments and the function itself
	
	local args = {}
	for i=2, #tokens do
		args[i-1] = tokens[i]
	end
	
	local expectedArgs = t[1]
	local func = t[2]
	
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
	
	local sprite = Sprite.new(parent.images[img], x, y, z)
	if parent.sprites[img] == nil then
		parent.sprites[img] = sprite
	else
		local num = 2
		while parent.sprites[img..num] ~= nil do
			num = num + 1
		end
		parent.sprites[img..num] = sprite
	end
	print("Placed sprite \""..img.."\" at "..x..", "..y..", "..z)
end}

Commands.camera = {2, function(parent, args)
	local x = tonumber(args[1])
	local y = tonumber(args[2])
	parent.cam_x = x
	parent.cam_y = y
	print("Moved camera to "..x..", "..y)
end}

Commands.load = {1, function(parent, args)
	local scene = args[1]
	loadScene(scene)
end}

Commands.pause = {0, function(parent, args)
	parent.paused = true
end}

Commands.clear = {0, function(parent, args)
	parent.sprites = {}
end}

Commands.remove = {1, function(parent, args)
	parent.sprites[args[1]] = nil
end}

return Commands