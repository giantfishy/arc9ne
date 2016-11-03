-- AUXILIARY.LUA - auxiliary functions to make stuff easier and more legible

function splitStr(str, split)
	if split == nil then split = " " end
	
	local tokens = {}
	local index = 1
	local previndex = 1
	while index ~= nil do
		index = str:find(split, index)
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

function startsWith(str, start)
	return str:find(start) == 1
	--return (str:sub(1, start:len()) == start)
end

function endsWith(str, suffix)
	return str:find(suffix) == (str:len() - suffix:len() + 1)
end

function parseHex(hex)
	-- this is quite a mess but i'm likely not going to look at it ever again
	hex = tostring(hex)
	if startsWith(hex, "#") then hex = hex:sub(2) end
	local r = hex:sub(1, 2)
	local g = hex:sub(3, 4)
	local b = hex:sub(5, 6)
	local color = {r, g, b}
	for i=1,3 do
		local chan = color[i]
		local result = 0
		for j=1,2 do
			local c = chan:sub(j, j)
			if tonumber(c) == nil then
				local index = string.find("ABCDEF", c)
				if index ~= nil then
					c = index + 9
				else
					c = 0
				end
			else
				c = tonumber(c)
			end
			result = result + (c * 16^(2-j))
		end
		color[i] = result
	end
	return color
end

function encodeHex(rgb)
	local result = "#"
	
	for i = 1, 3 do
		local a = math.floor(rgb[i] / 16) -- first digit
		local b = rgb[i] - 16*a -- second digit
		
		for j, d in ipairs({a, b}) do
			if d >= 10 then
				d = string.sub("ABCDEF", d-9, d-9)
				if j == 1 then a = d else b = d end -- eugh
			end
		end
		
		result = result..a..b
	end
	
	return result
end

function lerpColor(c1, c2, amt)
	local result = {}
	for i=1,3 do
		result[i] = c1[i] + amt*(c2[i] - c1[i])
	end
	return result
end