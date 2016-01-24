local Splash = require('states/splash')
local Menu = require('states/menu')
local Comic = require('states/comic')
local Charselect = require('states/charselect')

require('auxiliary')

local allStates = {}
local state = nil
local settings = nil
local fonts = {}
local audio = {}

function love.load()
	settings = loadSettings()
	
	love.audio.setVolume(tonumber(settings.volume))
	audio["menu"] = love.audio.newSource("sound/menu.ogg")
	audio["menu"]:setLooping(true)
	
	fonts["title"] = love.graphics.newFont("fonts/CaviarDreams_Bold.ttf", 60)
	fonts["selected"] = love.graphics.newFont("fonts/CaviarDreams_Bold.ttf", 36)
	fonts["menuItem"] = love.graphics.newFont("fonts/CaviarDreams.ttf", 28)
	fonts["small"] = love.graphics.newFont("fonts/CaviarDreams.ttf", 20)
	
	allStates["splash"] = Splash.new()
	allStates["menu"] = Menu.new()
	allStates["comic"] = Comic.new()
	allStates["charselect"] = Charselect.new()
	
	state = allStates.splash
	if settings.skipSplash then
		changeState("menu")
	end
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
		resizeWindow()
	end
	
	if stateType == "comic" then
		newState = Comic.new()
		allStates.comic = newState
		if settings.view3D == true and settings.fullscreen == false then
			local w = love.graphics.getWidth()
			love.window.setMode(w, 3 * w / 8)
		end
	end
	
	if newState ~= nil then state = newState end
	if state == allStates.comic then state:makeCanvases() end
	
	love.audio.stop()
	if audio[stateType] ~= nil then audio[stateType]:play() end
	if settings.volume == 0 then love.audio.pause() end
end

function resizeWindow()
	local resolution = splitStr(settings.resolution, "x")
	love.window.setMode(resolution[1], resolution[2], {fullscreen=settings.fullscreen, borderless=false})
end

function loadScene(filename)
	if state == allStates.comic then
		state:load(filename)
	end
end

function getSettings()
	return settings
end

function setSettings(newSettings)
	settings = newSettings
	love.filesystem.write("settings.txt", "")
	for key, value in pairs(settings) do
		love.filesystem.append("settings.txt", key.."="..tostring(value).."\r\n")
	end
end

function playAudio(name)
	audio[name]:play()
end

function setFont(name)
	love.graphics.setFont(fonts[name])
end

function drawText(text, x, y, align)
	local width = love.graphics.getFont():getWidth(text)
	local height = love.graphics.getFont():getAscent()
	
	if align == "right" then
		x = x - width
	elseif align == "center" then
		x = x - width/2
	end
	love.graphics.printf(text, math.floor(x), math.floor(y - height*0.6), love.graphics.getWidth(), "left")
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
			
			if value == "true" or value == "false" then
				value = (value == "true")
			elseif tonumber(value) ~= nil then
				value = tonumber(value)
			end
			
			result[key] = value
			--print(key.." = "..tostring(value))
		end
	end
	
	settingsFile:close()
	
	return result
end

function resetSettings()
	love.filesystem.remove("settings.txt")
	settings = loadSettings()
end