local Scene = require('scene')

local currentscene = nil

local mainCanvas = nil
local lefteye = nil
local righteye = nil

local view3D = true

local w = love.graphics.getWidth()
local h = love.graphics.getHeight()

function love.load()
	currentscene = Scene.new("act1/scene1")
	
	-- TODO: make the canvas sizes and window size customisable
	mainCanvas = love.graphics.newCanvas(w, h)
	lefteye = love.graphics.newCanvas(w/2, h)
	righteye = love.graphics.newCanvas(w/2, h)
end

function love.draw()
	if currentscene ~= nil then
		if view3D then
			local eyedist = 0.1
			currentscene:draw(lefteye, eyedist/2)
			currentscene:draw(righteye, -eyedist/2)
			
			love.graphics.draw(righteye, 0, 0)
			love.graphics.draw(lefteye, w/2, 0)
		else
			currentscene:draw(mainCanvas)
			
			love.graphics.draw(mainCanvas, 0, 0)
		end
	end
end

function love.update(dt)
	if currentscene ~= nil then
		local finished = currentscene:update(dt)
		if finished then
			-- go to the next one?
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	currentscene.paused = false
end