
-- Obtains either a empty table or the user's data
_tardis.get_user = function (user_name)
    local user = _tardis.store:get_string(user_name)
    if user == nil or user == "" then
        _tardis.tools.log("Didn't find a user by '"..user_name.."' name, creation occured")
        user = {}
    else
        --_tardis.tools.log("Found '"..user_name.."' with '"..user.."' data")
        user = minetest.deserialize(user)
        --_tardis.tools.log("Returning '"..minetest.serialize(user).."'")
    end
    return user
end

-- Saves the user's data
_tardis.save_user = function (user_name, user_data)
    local user = _tardis.get_user(user_name)
    if user ~= user_data then
        -- Only save what you need
        user = user_data
        _tardis.store:set_string(user_name, minetest.serialize(user))
    end
end

-- Makes new user data
_tardis.make_new_user = function (user_name)
    local user = _tardis.get_user(user_name)
    if user.version ~= nil then
        _tardis.tools.log("User '"..user_name.."' was found with data, rewriting data")
    end
    user.version = tardis.VERSION -- Just a check to verify this version running is the same as that of the data
    user.power = { -- Because doing things cost power
        generating = 0, -- How much is generated per second
        capacity = 0, -- Current capacity (when 0 all systems are off till 50% capacity is regained, this also means you will be restored )
        max_capacity = 0, -- maximum capacity able to be stored by the tardis (generators store small amounts but produce large amounts of power, batteries store large amounts but produce very little power)
        active = false -- If the tardis is powered, true enables lights ahd what not
    }
    user.validation = false -- If this tardis is to be counted as a real thing (on place will set this to true because then it's true)
    user.waypoints = {} -- Name and {pos, dir} for this tardis. (Set by tardis:waypoint_console, and API)
    -- All these are set by tardis:navigation_console (out_pos, prev_out_pos, dest_pos)
    user.in_pos = vector.new(0, 0, 0) -- Where to spawn the user so they are inside the tardis (Default's to empty)
    user.out_pos = vector.new(0, 0, 0) -- Where to spawn the user when they exit the tardis (Default's to empty)
    user.prev_out_pos = vector.new(0, 0, 0) -- Stores last position (used for when dematerialized but then ran out of power)
    user.dest_pos = vector.new(0, 0, 0) -- Where the tardis is pointing to goto (Not used if just specifying to dematerialize, else appears here on rematerialize)
    user.dest_dir = 0 -- Face (North, N, +Z) direction
    -- See dynamic_textures.lua for further details
    user.exterior_theme = _tardis.exterior_skins.colored.blue -- "tardis:tardis"
    user.interior_theme = _tardis.interior_skins.light -- "tardis:light_wall"
    user.security = { -- Can be changed only once a tardis:security_manager is placed (And owner is the only one allowed to change it)
        companions = {}, -- Who's allowed on board, (anyone not in this list could be taking damage, anyone on this list could be getting healed etc.)
        pilots = {}, -- Who is authorized to pilot the tardis (only the owner can change security settings, including passive systems etc.)
        interior_weapons = { -- Damages anyone not a companion or pilot (also excludes owner, of course)
            state = false, -- Consumes 1 power
            damage = 1 -- How many HP is dealt per 3 seconds
        },
        exterior_weapons = { -- Damages anyone 2 blocks away from the tardis (who is not owner/companion/pilot)
            state = false, -- Consumes 1 power
            damage = 1 -- How many HP is dealt per 3 seconds
        },
        alert_on_intruder = true -- Sends a message to owner and all companions and pilots of who and what they hold and their health (only if they are not allowed inside)
        -- Doesn't say where though, so someone could teleport in via vortex manipulator or even their tardis (which will trigger only when they leave it)
    }
    user.physics = {
        materialized = false, -- Default to in vortex (decides if a user can exit, true=phyisical, false=not in world)
        respect_grav = false, -- If true then on rematerialization it will fall thru air/water/lava and snow. (else it will maintain it's position)
        floatation = false, -- If true then the tardis will not fall thru water/lava, but will fall only thru air and snow. (else it will fall thru them)
        artifical_env = false, -- Produces a 2 block radius around the tardis of breathable air, great for underwater or under lava.
        artifical_grav = false -- On exiting the tardis gravity is reduced to 0, allowing anyone to float (up to a 2 block radius)
    }
    user.passive_systems = { -- Applied to owner/companions/pilots
        health = {
            state = false, -- Consumes 1 power, 2 if it healed someone
            rate = 1 -- How many HP is replenished per 3 seconds
        },
        repair = { -- (This feature will be comming soon)
            state = false, -- Consumes 1 power, 2 if it repaired something someone
            rate = 1 -- How many percents is replenished per 3 seconds
        },
        recharge = { -- Only avalible if technic is installed (This feature will be comming soon)
            state = false, -- Consumes 1 power, 2 if it recharged something of someone
            rate = 1 -- How many percents is replenished per 3 seconds
        },
        feeding = { -- Only avalible if either MCL(2&5) or stamina is installed (This feature will be comming soon)
            state = false, -- Consumes 1 power, 2 if it feed someone
            rate = 1 -- How many hunger points is replenished per 3 seconds
        }
    }
    -- Save it
    _tardis.save_user(user_name, user)
    return user -- Just to prevent needing to get the user yet again just to update the table
end

-- Attempts to return a table of {success=bool, errmsg=string, pos=table, dir=number} of the waypoint
_tardis.get_waypoint = function (user_name, waypoint_name)
    local user = _tardis.get_user(user_name)
    for _, k in ipairs(user.waypoints) do
        if k.name == waypoint_name then
            return {success=true, errmsg="", pos=k.pos, dir=k.dir}
        end
    end
    return {success=false, errmsg="No such waypoint '"..waypoint_name.."' for user '"..user_name.."'.", pos=vector.new(0, 0, 0), dir=0}
end

-- Sets a waypoint given it's name, position for where it should be, and it's direction
_tardis.set_waypoint = function (user_name, waypoint_name, pos, dir)
    local user = _tardis.get_user(user_name)
    local found = false
    local idx = 0
    for id, k in ipairs(user.waypoints) do
        if k.name == waypoint_name then
            found = true
            idx = id
            break
        end
    end
    if found then
        user.waypoints[idx].pos = vector.new(pos.x, pos.y, pos.z)
        user.waypoints[idx].dir = dir
    else
        table.insert(user.waypoints, {name = waypoint_name, pos = vector.new(pos.x, pos.y, pos.z), dir = dir})
    end
    _tardis.save_user(user_name, user)
end

-- Checks if the given player_name is a companion of the user
_tardis.is_companion = function (user_name, player_name)
    local user = _tardis.get_user(user_name)
    for _, k in ipairs(user.security.companions) do
        if k == player_name then
            return true
        end
    end
    return false
end

-- Attempts to add the given player_name to user
_tardis.add_companion = function (user_name, player_name)
    local user = _tardis.get_user(user_name)
    if _tardis.is_companion(user_name, player_name) == true then
        return {success=false, errmsg="Companion '"..player_name.."' is already a companion for user '"..user_name.."'."}
    end
    table.insert(user.security.companions, player_name)
    _tardis.save_user(user_name, user)
    return {success=true, errmsg=""}
end

-- Attempts to remove the given player_name from user
_tardis.remove_companion = function (user_name, player_name)
    local user = _tardis.get_user(user_name)
    if _tardis.is_companion(user_name, player_name) == false then
        return {success=false, errmsg="No such companion '"..player_name.."' for user '"..user_name.."'."}
    end
    local new_list = {}
    for _, k in ipairs(user.security.companions) do
        if k ~= player_name then
            table.insert(new_list, k)
        end
    end
    user.security.companions = new_list
    _tardis.save_user(user_name, user)
    return {success=true, errmsg=""}
end

-- Is the given player_name a pilot of user
_tardis.is_pilot = function (user_name, player_name)
    local user = _tardis.get_user(user_name)
    for _, k in ipairs(user.security.pilots) do
        if k == player_name then
            return true
        end
    end
    return false
end

-- Attempts to add given player_name to user
_tardis.add_pilot = function (user_name, player_name)
    local user = _tardis.get_user(user_name)
    if _tardis.is_pilot(user_name, player_name) == true then
        return {success=false, errmsg="Pilot '"..player_name.."' is already a pilot for user '"..user_name.."'."}
    end
    table.insert(user.security.pilots, player_name)
    _tardis.save_user(user_name, user)
    return {success=true, errmsg=""}
end

-- Attempts to remove given player_name from user
_tardis.remove_pilot = function (user_name, player_name)
    local user = _tardis.get_user(user_name)
    if _tardis.is_pilot(user_name, player_name) == false then
        return {success=false, errmsg="No such pilot '"..player_name.."' for user '"..user_name.."'."}
    end
    local new_list = {}
    for _, k in ipairs(user.security.pilots) do
        if k ~= player_name then
            table.insert(new_list, k)
        end
    end
    user.security.pilots = new_list
    _tardis.save_user(user_name, user)
    return {success=true, errmsg=""}
end

-- Attempts to promote the given player_name for user
_tardis.promote = function (user_name, player_name)
    local at = _tardis.is_allowed(user_name, player_name)
    if at.rank == "" then
        -- Add them as a companion if they are not allowed
        _tardis.add_companion(user_name, player_name)
        return {success=true, errmsg="'"..player_name.."' is now rank Companion for '"..user_name.."'."}
    elseif at.rank == "Companion" then
        -- Promote them to Pilot
        _tardis.remove_companion(user_name, player_name)
        _tardis.add_pilot(user_name, player_name)
        return {success=true, errmsg="'"..player_name.."' is now rank Pilot for '"..user_name.."'."}
    elseif at.rank == "Pilot" or at.rank == "Owner" then
        -- Do nothing on Pilot or Owner
        return {success=false, errmsg="You can't promote '"..player_name.."' any higher."}
    end
end

-- Attempts to demote the given player_name for user
_tardis.demote = function (user_name, player_name)
    local at = _tardis.is_allowed(user_name, player_name)
    if at.rank == "" then
        -- Do nothing if they are not allowed (already)
        return {success=false, errmsg="Player '"..player_name.."' isn't allowed in "..user_name.."'s Tardis."}
    elseif at.rank == "Companion" then
        -- Remove all rank from them if they are Companion
        _tardis.remove_companion(user_name, player_name)
        return {success=true, errmsg="'"..player_name.."' has been removed from "..user_name.."'s Tardis."}
    elseif at.rank == "Pilot" then
        -- Demote them from Pilot to Companion
        _tardis.remove_pilot(user_name, player_name)
        _tardis.add_companion(user_name, player_name)
        return {success=true, errmsg="'"..player_name.."' is now rank Companion for '"..user_name.."'."}
    elseif at.rank == "Owner" then
        -- Do nothing on Owner
        return {success=false, errmsg="You can't demote '"..player_name.."' any lower."}
    end
end

-- Returns if the given player is allowed in the user's tardis (if false then we need to report intruder)
-- Also returns what their rank is (I.E. Owner, Pilot, Companion)
_tardis.is_allowed = function (user_name, player_name)
    if user_name == player_name then
        return {allowed=true, rank="Owner"}
    elseif _tardis.is_pilot(user_name, player_name) == true then
        return {allowed=true, rank="Pilot"}
    elseif _tardis.is_companion(user_name, player_name) == true then
        return {allowed=true, rank="Companion"}
    else
        return {allowed=false, rank=""}
    end
end
