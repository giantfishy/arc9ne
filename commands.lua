local Sprite = require('sprite')

local Commands = {}

Commands.parse = function(parent, text)
	local tokens = splitStr(text)
	
	local functionName = tokens[1]
	local func = Commands[functionName]
	
	local args = {}
	for i=2, #tokens do
		args[i-1] = tokens[i]
	end
	
	local expectedArgs = Commands.args[functionName]
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

-- number of arguments expected for each command:

Commands.args = {}
Commands.args.place = 4
Commands.args.camera = 2
Commands.args.load = 1
Commands.args.pause = 0

-- commands:

Commands.place = function(parent, args)
	local img = args[1]
	local x = tonumber(args[2])
	local y = tonumber(args[3])
	local z = tonumber(args[4])
	parent.sprites[#parent.sprites+1] = Sprite.new(parent.images[img], x, y, z)
	print("Placed sprite \""..img.."\" at "..x..", "..y..", "..z)
end

Commands.camera = function(parent, args)
	local x = tonumber(args[1])
	local y = tonumber(args[2])
	parent.cam_x = x
	parent.cam_y = y
	print(x, y)
	print("Moved camera to "..x..", "..y)
end

Commands.load = function(parent, args)
	local scene = args[1]
	loadScene(scene)
end

Commands.pause = function(parent, args)
	parent.paused = true
end

return Commands