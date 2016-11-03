Splash = require('states/splash')
Menu = require('states/menu')
Comic = require('states/comic')
Charselect = require('states/charselect')

require('auxiliary')

local allStates = {}
local state = nil
local pausemenu = false
local settings = nil
local fonts = {}
local audio = {}

char_img = {}

function love.load()
	settings = loadSettings()
	local stateNames = {"splash", "menu", "charselect", "comic"}
	
	love.audio.setVolume(tonumber(settings.volume))
	for i, name in ipairs({"menu", "charselect"}) do
		local src = love.audio.newSource("sound/"..name..".ogg")
		src:setLooping(true)
		
		local data = {}
		data.src = src
		data.vol = 2 - i -- menu volume = 1, charselect volume = 0
		data.dvol = 0 -- speed of change of volume
		audio[name] = data
	end
	
	fonts["title"] = love.graphics.newFont("fonts/CaviarDreams_Bold.ttf", 60)
	fonts["selected"] = love.graphics.newFont("fonts/CaviarDreams_Bold.ttf", 36)
	fonts["menuItem"] = love.graphics.newFont("fonts/CaviarDreams.ttf", 28)
	fonts["small"] = love.graphics.newFont("fonts/CaviarDreams.ttf", 20)
	
	local chars = {"alex", "liam", "noah", "hana", "diana", "mark", "nika", "izzy", "cleo", "felix", "lucas", "petra"}
	for i, c in ipairs(chars) do
		char_img[chars[i]] = love.graphics.newImage("assets/char_icons/"..c..".tga")
	end
	
	for i, name in ipairs(stateNames) do
		local cl = name:sub(1, 1):upper()..name:sub(2) -- capitalise first letter
		allStates[name] = _G[cl].new()
	end
	
	state = allStates.splash
	if settings.skipSplash then
		changeState("menu")
	end
end

function love.draw()
	if pausemenu then
		allStates.comic:draw()
		
		love.graphics.setColor(0, 0, 0, 150)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	end
	state:draw()
end

function love.update(dt)
	for name, data in pairs(audio) do
		data.vol = data.vol + data.dvol*dt
		if data.vol > 1 then data.vol = 1 end
		if data.vol < 0 then data.vol = 0 end
		
		data.src:setVolume(data.vol)
	end
	
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
	
	local spd = 4
	if stateType == "menu" then
		audio.menu.src:play()
		audio.charselect.src:play()
	end
	if (stateType == "charselect" and state == allStates.menu) then
		audio.menu.dvol = -spd
		audio.charselect.dvol = spd
	elseif (stateType == "menu" and (state == allStates.charselect or pausemenu)) then
		audio.menu.dvol = spd
		audio.charselect.dvol = -spd
	elseif stateType == "comic" and not pausemenu then
		audio.charselect.vol = 0.5
		audio.charselect.dvol = -0.5
	end
	
	if audio[stateType] ~= nil then
		local src = audio[stateType].src
		if src ~= nil then src:play() end
		if settings.volume == 0 then love.audio.pause() end
	end
	
	if stateType == "comic" then
		if pausemenu then
			pausemenu = false
			allStates.menu = Menu.new()
		else
			newState = Comic.new()
			allStates.comic = newState
			if settings.view3D ~= "off" and settings.fullscreen == false then
				local w = love.graphics.getWidth()
				love.window.setMode(w, 3 * w / 8)
			end
		end
	elseif stateType == "menu" then
		if pausemenu then
			if state == allStates.menu then pausemenu = false end
		elseif state == allStates.comic then
			pausemenu = true
		end
		newState = Menu.new(pausemenu)
		allStates.menu = newState
	end
	
	if newState ~= nil then state = newState end
	if state == allStates.comic then state:makeCanvases() end
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

function sceneExists(filename)
	if love.filesystem.isFile("story/"..filename..".txt") then
		return true
	end
	return false
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
		for line in love.filesystem.lines("defaultsettings.txt") do
			settingsFile:write(line.."\r\n")
		end
		settingsFile:close()
	end
	
	local settingsFile = fs.newFile("settings.txt", "r")
	for line in settingsFile:lines() do
		line = line:gsub("\r\n?", "")
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