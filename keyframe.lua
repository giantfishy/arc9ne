-- KEYFRAME.LUA - holds information and commands for a specific point in time

local Keyframe = {}
Keyframe.__index = Keyframe

function Keyframe.new(t, prev)
	local self = setmetatable({}, Keyframe)
	self.t = t
	self.commands = {}
	
	return self
end

function Keyframe.addCommand(self, c)
	self.commands[#self.commands + 1] = c
end

return Keyframe