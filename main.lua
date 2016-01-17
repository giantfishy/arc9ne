local Menu = require('states/menu')
local Comic = require('states/comic')
local Splash = require('states/splash')

local allStates = {}
local state = nil
local settings = nil
local fonts = {}

function love.load()
	settings = loadSettings()
	
	fonts.title = love.graphics.newFont("fonts/CaviarDreams_Bold.ttf", 60)
	fonts.selected = love.graphics.newFont("fonts/CaviarDreams_Bold.ttf", 36)
	fonts.menuItem = love.graphics.newFont("fonts/CaviarDreams.ttf", 28)
	
	allStates["menu"] = Menu.new()
	allStates["comic"] = Comic.new(settings)
	allStates["splash"] = Splash.new()
	
	state = allStates.splash
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

function changeState(stateType)
	local newState = allStates[stateType]
	
	if state == allStates.splash and newState ~= nil then
		love.window.setMode(settings.width, settings.height, {fullscreen=settings.fullscreen, borderless=false})
	end
	
	if newState ~= nil then state = newState end
	if state == allStates.comic then state:makeCanvases() end
end

function loadScene(filename)
	if state == allStates.comic then
		state:load(filename)
	end
end

function setFont(name)
	love.graphics.setFont(fonts[name])
end

-- function to load the settings.txt and make a table out of it
function loadSettings()
	local result = {}
	local fs = love.filesystem
	
	local filename = "settings.txt"
	--if not fs.exists(filename) then
	if true then -- TEMPORARY change, so i can just change defaultsettings.txt each time
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