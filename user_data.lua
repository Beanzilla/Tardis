
-- Obtains either a empty table or the user's data
_tardis.get_user = function (user_name)
    local user = _tardis.store:get_string(user_name) or nil
    if user == nil then
        _tardis.tools.log("Didn't find a user by '"..user_name.."' name, creation occured")
        user = {}
    else
        user = minetest.deserialize(user) or {}
    end
    return user
end

-- Saves the user's data
_tardis.save_user = function (user_name, user_data)
    local user = _tardis.get_user(user_name)
    user = user_data
    _tardis.store:set_string(user_name, minetest.serialize(user))
end

-- Makes new user data
_tardis.make_new_user = function (user_name)
    local user = _tardis.get_user(user_name)
    if user == nil then
        user = {}
    end
    if _tardis.tools.tableContainsValue(user, "version") then
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
            state = false,
            damage = 1 -- How many HP is dealt per 3 seconds
        },
        exterior_weapons = { -- Damages anyone 2 blocks away from the tardis (who is not owner/companion/pilot)
            state = false,
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
            state = false,
            rate = 1 -- How many HP is replenished per 3 seconds
        },
        repair = { -- (This feature will be comming soon)
            state = false,
            rate = 1 -- How many percents is replenished per 3 seconds
        },
        recharge = { -- Only avalible if technic is installed (This feature will be comming soon)
            state = false,
            rate = 1 -- How many percents is replenished per 3 seconds
        },
        feeding = { -- Only avalible if either MCL(2&5) or stamina is installed (This feature will be comming soon)
            state = false,
            rate = 1 -- How many hunger points is replenished per 3 seconds
        }
    }
    -- Save it
    _tardis.save_user(user_name, user)
    return user -- Just to prevent needing to get the user yet again just to update the table
end
