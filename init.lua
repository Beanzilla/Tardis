
-- Storage containers for both the public and _private apis
tardis = {}
_tardis = {}

-- Some info about the current version being used
_tardis.MODPATH = minetest.get_modpath("tardis")
tardis.VERSION = "1.0.0-dev"
_tardis.store = minetest.get_mod_storage()

-- Allow calling lua code easily and custom
_tardis.do_src = function (directory, filename)
    if filename ~= nil then
        dofile(_tardis.MODPATH .. DIR_DELIM .. directory .. DIR_DELIM .. filename .. ".lua")
    else
        dofile(_tardis.MODPATH .. DIR_DELIM .. directory .. ".lua")
    end
end

-- Detect what gamemode we are running in (General games only, more specific will not be detected)
_tardis.GAMEMODE = "???"
if minetest.registered_nodes["default:stone"] then
    _tardis.GAMEMODE = "MTG"
elseif minetest.registered_nodes["mcl_core:stone"] then
    _tardis.GAMEMODE = "MCL" -- May be MCL2 or MCL5
    if minetest.registered_nodes["mcl_deepslate:deepslate"] then
        _tardis.GAMEMODE = "MCL5"
    else
        _tardis.GAMEMODE = "MCL2"
    end
elseif minetest.registered_nodes["nc_terrain:stone"] then
    _tardis.GAMEMODE = "NC"
end

-- Initalize _private tools (helper functions)
_tardis.do_src("toolbelt")

-- Dump out version and gamemode on start up
_tardis.tools.log("Version:  "..tostring(tardis.VERSION))
_tardis.tools.log("Gamemode: "..tostring(_tardis.GAMEMODE))

-- Initalize _private user (using modstorage for storing tardis information)
_tardis.do_src("dynamic_textures") -- For Exterior and Interior "skins"
_tardis.do_src("user_data") -- User data for tardis mod is initilized here

-- Initalize exteriors
_tardis.do_src("exterior", "init") -- Initalizes all exterior skins

-- Initalize interiors (walls and lights, no consoles)
_tardis.do_src("interior", "init") -- Initalizes both dark and light themes for interior, use swap_node and find_node_in_area for changing
