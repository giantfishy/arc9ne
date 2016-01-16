local Menu = require('states/menu')
local Comic = require('states/comic')

local Scene = require('scene')

local state = nil
local settings = nil

function love.load()
	settings = loadSettings()
	state = Comic.new(settings)
	state.currentscene = Scene.new("act1/scene1")
end

function love.draw()
	state:draw()
end

function love.update(dt)
	state:update(dt)
end

function love.keypressed(key, scancode, isrepeat)
	state:keypressed(key)
end

-- function to load the settings.txt and make a table out of it
function loadSettings()
	local result = {}
	local fs = love.filesystem
	
	local filename = "settings.txt"
	if not fs.exists(filename) then
		print("Writing default settings.\n")
		local settingsFile = fs.newFile("settings.txt", "w")
		for line in io.lines(love.filesystem.getSourceBaseDirectory().."/arc9ne/defaultsettings.txt") do
			settingsFile:write(line.."\r\n")
		end
		settingsFile:close()
	end
	
	local settingsFile = fs.newFile("settings.txt", "r")
	for line in settingsFile:lines() do
		local split = line:find("=")
		if split then
			local key = line:sub(1, split-1)
			local value = line:sub(split+1)
			
			if value == "true" or value == "false" then value = (value == "true") end
			
			result[key] = value
			print(key.." = "..tostring(value))
		end
	end
	
	return result
end