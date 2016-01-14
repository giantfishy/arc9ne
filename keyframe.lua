local Keyframe = {}
Keyframe.__index = Keyframe

function Keyframe.new(t, prev)
	local self = setmetatable({}, Keyframe)
	self.t = t
	self.commands = {}
	
	self.cam_x = 0
	self.cam_y = 0
	if prev ~= nil then
		self.cam_x = prev.cam_x
		self.cam_y = prev.cam_y
	end
	
	return self
end

function Keyframe.addCommand(self, c)
	self.commands[#self.commands + 1] = c
	
	local tokens = splitStr(c)
	if tokens[1] == "camera" then
		self.cam_x = tonumber(tokens[2])
		self.cam_y = tonumber(tokens[3])
	end
end

function splitStr(str)
	local tokens = {}
	local index = 1
	local previndex = 1
	while index ~= nil do
		index = str:find(" ", index)
		if index == nil then
			tokens[#tokens+1] = str:sub(previndex)
			break
		end
		tokens[#tokens+1] = str:sub(previndex, index-1)
		index = index + 1
		previndex = index
	end
	return tokens
end

return Keyframe