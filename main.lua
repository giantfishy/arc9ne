local Scene = require('scene')

local currentscene = nil

function love.load()
	currentscene = Scene.new("act1/scene1")
end

function love.draw()
	if currentscene ~= nil then
		currentscene:draw()
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