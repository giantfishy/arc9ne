local Scene = require('scene')

local currentscene = nil
local lefteye = nil
local righteye = nil

function love.load()
	currentscene = Scene.new("act1/scene1")
	lefteye = love.graphics.newCanvas(500, 500)
	righteye = love.graphics.newCanvas(500, 500)
end

function love.draw()
	if currentscene ~= nil then
		local eyedist = 0.02
		currentscene:draw(lefteye, eyedist/2)
		currentscene:draw(righteye, -eyedist/2)
	end
	
	love.graphics.draw(righteye, 0, 0)
	love.graphics.draw(lefteye, 500, 0)
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