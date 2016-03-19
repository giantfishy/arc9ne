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
	
	-- check if a keyframe already exists at this time - if so, merge them
	for i, f in ipairs(self.data) do
		if f.t == t then
			for key, value in pairs(values) do
				if f.values[key] == nil then f.values[key] = value end
			end
			f.style = style
			return
		end
	end
	
	self.data[#self.data+1] = keyframe
	
	-- make sure keyframes are in order
	table.sort(self.data, function(a, b) return a.t < b.t end)
end

local styles = {}

styles.linear = function(amt)
	return amt
end

styles.instant = function(amt)
	return 0
end

styles.decel = function(amt)
	local sharpness = 10
	local endpoint = math.pow(0.5, sharpness)
	local y = 1 - (math.pow(0.5, amt*sharpness) - amt*endpoint)
	return y
end

styles.accel = function(amt)
	return 1 - styles.decel(1 - amt)
end

styles.ease = function(amt)
	if amt < 0.5 then
		return styles.accel(amt*2)/2
	else
		return 0.5 + styles.decel(amt*2-1)/2
	end
end

styles.random = function(amt)
	return math.random()
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
				local initial = from.values[var]
				local final = to.values[var]
				local amt = (t - from.t) / (to.t - from.t)
				
				if func == nil then func = styles.linear end
				
				if tonumber(initial) == nil or tonumber(final) == nil then
					self.parent[var] = hexLerp(initial, final, amt, func)
				else
					self.parent[var] = initial + func(amt)*(final - initial)
				end
			end
		end
	end
end

function hexLerp(from, to, amt, func)
	from = parseHex(from)
	to = parseHex(to)
	
	local result = {}
	for i = 1, 3 do
		result[i] = math.floor(from[i] + func(amt)*(to[i] - from[i]))
	end
	
	return encodeHex(result)
end

return Keyframer