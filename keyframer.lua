-- KEYFRAMER.LUA - for setting up keyframes to change values over time

local Keyframer = {}
Keyframer.__index = Keyframer

function Keyframer.new(parent)
	local self = setmetatable({}, Keyframer)
	
	self.parent = parent
	self.data = {} -- array of all the keyframes
	
	return self
end

function Keyframer.add(self, t, style, values)
	local keyframe = {}
	keyframe.t = t
	keyframe.style = style
	keyframe.values = values
	
	self.data[#self.data+1] = keyframe
end

local styles = {}
styles.linear = function(from, to, amt)
	return from + amt*(to - from)
end
styles.instant = function(from, to, amt)
	return from
end

function Keyframer.update(self, t)
	if self.parent == nil then return end
	
	local from = nil -- the current previous keyframe
	local index = nil -- current index
	
	-- find current previous keyframe
	for i, key in ipairs(self.data) do
		if key.t <= t then
			from = key
			index = i
		end
	end
	
	if from ~= nil then
		for key, value in pairs(from.values) do
			-- find next keyframe with a value for that key
			local to = nil
			for i = index+1, #self.data do
				if self.data[i].values[key] ~= nil then
					to = self.data[i]
					break
				end
			end
			
			if to ~= nil then
				local func = styles[to.style] -- get ease function
				local amt = (t - from.t) / (to.t - from.t)
				
				if func == nil then func = styles.linear end
				self.parent[key] = func(value, to.values[key], amt)
			end
		end
	end
end

return Keyframer