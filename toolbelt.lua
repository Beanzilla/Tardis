
-- A collection of utility functions for making lua less difficult
_tardis.tools = {}
local tools = _tardis.tools

-- Centralize logging
tools.log = function (input)
    minetest.log("action", "[tardis] "..tostring(input))
end

-- Centralize errors
tools.error = function (input)
    -- Include Version, Gamemode including error message so if they report the logs verbate then we get extra details
    tools.log("Version:  "..tostring(tardis.VERSION))
    tools.log("Gamemode: "..tostring(_tardis.GAMEMODE))
    tools.log("E "..input) -- Also dump the message to the logs, incase they closed it but then wanted to report it
    error("[tardis] "..tostring(input))
end

-- Returns a table of the string split by the given seperation string
tools.split = function (inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

-- Returns true or false if search string is in inputstring
tools.contains = function(inputstr, search)
    if string.match(inputstr, search) then
        return true
    end
    return false
end

-- Returns space seperated position (Also strips extra precission)
tools.pos2str = function (pos)
    -- Because minetest's pos_to_string is a bit harder to parse
    return "" .. tostring(math.floor(pos.x)) .. " " .. tostring(math.floor(pos.y)) .. " " .. tostring(math.floor(pos.z))
end

-- Returns a xyz vector from space seperated position
tools.str2pos = function (str)
    local pos = tools.split(str, " ")
    return vector.new(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3]))
end

-- Returns 0, 90, 180, 270 based on direction given (assumes degree)
tools.to4dir = function (dir)
    local dir4 = math.floor(dir) / 90
    if dir4 > 3.5 or dir4 < 0.5 then
        return 180 -- South, -Z
    elseif dir4 > 2.5 and dir4 < 3.5 then
        return 270 -- East, +X
    elseif dir4 > 1.5 and dir4 < 2.5 then
        return 0 -- North, +Z
    elseif dir4 > 0.5 and dir4 < 3.5 then
        return 90 -- West, -X
    end
    tools.log("to4dir(" .. tostring(dir) .. ") failed with " .. tostring(dir4))
    return -1
end

-- Returns a {name and direction} given direction (assumes degrees)
tools.dir2str = function (dir)
    local dir4 = tools.to4dir(dir)
    if dir4 == 0 then
        return {name="North", short_name="N", dir="+Z"}
    elseif dir4 == 90 then
        return {name="West", short_name="W", dir="-X"}
    elseif dir4 == 180 then
        return {name="South", short_name="S", dir="-Z"}
    elseif dir4 == 270 then
        return {name="East", short_name="E", dir="+X"}
    end
    tools.log("dir2str(" .. tostring(dir) .. ") failed with " .. tostring(dir4))
    return {name="???", dir="???"}
end

-- Flips the dir given to it's opposite (assumes degrees)
tools.flip_dir = function (dir)
    local my_dir = tools.to4dir(math.floor(dir))
    local look = tools.dir2str(my_dir)
    if look.short_name == "N" then
        return 180 -- S
    elseif look.short_name == "S" then
        return 0 -- N
    elseif look.short_name == "E" then
        return 90 -- W
    elseif look.short_name == "W" then
        return 270 -- E
    end
    tools.log("flip_dir("..tostring(dir)..") is facing "..look.name.." ("..look.short_name..", "..look.dir..")")
end

-- Returns the param2 field (assumes given degrees)
tools.toParam2 = function (dir)
    local my_dir = tools.to4dir(math.floor(dir))
    if my_dir == 0 then
        return 0 -- N
    elseif my_dir == 270 then
        return 3 -- E
    elseif my_dir == 180 then
        return 2 -- S
    elseif my_dir == 90 then
        return 1 -- W
    end
    tools.log("toParam2("..tostring(dir)..") is facing "..tostring(my_dir))
end

-- Given radians returns degrees
tools.rad2deg = function (rads)
    return (rads * 180) / 3.14159
end

-- Given degrees returns radians
tools.deg2rad = function (deg)
    return (deg * 3.14159) / 180
end

-- Converts the given string so the first letter is uppercase (Returns the converted string)
tools.firstToUpper = function (str)
    return (str:gsub("^%l", string.upper))
end

-- https://stackoverflow.com/questions/2282444/how-to-check-if-a-table-contains-an-element-in-lua
-- Checks if a value is in the given table (True if the value exists, False otherwise)
tools.tableContainsValue = function (table, element)
    for key, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

tools.tableContainsKey = function (table, element)
    for key, value in pairs(table) do
        if key == element then
            return true
        end
    end
    return false
end

-- Given a table returns it's keys (Returns a table)
tools.tableKeys = function (t)
    local keys = {}
    for k, v in pairs(t) do
        table.insert(v)
    end
    return keys
end

-- Returns whole percentage given current and max values (defaults max to 100 if not given)
tools.getPercent = function (current, max)
    if max == nil then
        max = 100
    end
    return math.floor( (current / max) * 100 )
end

-- Returns whole number assuming given is a percent (limit's it to within a percent 0-100)
tools.makePercent = function (value)
    if value < 0 then
        value = 0
    end
    if value > 100 then
        value = 100
    end
    return math.floor(value)
end
