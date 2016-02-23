-- KEYFRAMER.LUA - for setting up keyframes to change values over time

local Keyframer = {}
Keyframer.__index = Keyframer

function Keyframer.new(parent)
	local self = setmetatable({}, Keyframer)
	
	self.parent = parent
	self.data = {} -- array of all the keyframes
	self.variables = {} -- array of all variables which this keyframer is responsible for
	
	return self
end

function Keyframer.add(self, t, style, values)
	local keyframe = {}
	keyframe.t = t
	keyframe.style = style
	keyframe.values = values
	
	for key, value in pairs(values) do
		self.variables[key] = true
	end
	
	self.data[#self.data+1] = keyframe
end

local styles = {}
styles.linear = function(from, to, amt)
	return from + amt*(to - from)
end
styles.instant = function(from, to, amt)
	return from
end
styles.cubic = function(from, to, amt)
	local y = 0.5 + (math.pow(math.abs(amt - 0.5), (1/3)) / (2*math.pow(0.5, (1/3))))
	if amt < 0.5 then y = 1 - y end
	return from + y*(to - from)
end
styles.ease = function(from, to, amt)
	local sharpness = 10
	local endpoint = math.pow(0.5, sharpness)
	local y = 1 - (math.pow(0.5, amt*sharpness) - amt*endpoint)
	return from + y*(to - from)
end

function Keyframer.update(self, t)
	if self.parent == nil then return end
	
	for var, bool in pairs(self.variables) do
		local from = nil -- start keyframe
		local index = nil -- index of start keyframe
		
		-- find last keyframe which has that variable
		for i, key in ipairs(self.data) do
			if key.t <= t and key.values[var] ~= nil then
				from = key
				index = i
			end
		end
		
		if from ~= nil then
			-- find next keyframe with a value for that key
			local to = nil
			for i = index+1, #self.data do
				if self.data[i].values[var] ~= nil then
					to = self.data[i]
					break
				end
			end
			
			if to ~= nil then
				local func = styles[to.style] -- get ease function
				local amt = (t - from.t) / (to.t - from.t)
				
				if func == nil then func = styles.linear end
				self.parent[var] = func(from.values[var], to.values[var], amt)
			end
		end
	end
end

return Keyframer