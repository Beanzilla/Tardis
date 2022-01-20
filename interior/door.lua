
minetest.register_node("tardis:interior_door", {
    description = "Tardis Interior Door",
    tiles = {"inside_door.png"},
    drawtype = "mesh",
    mesh = "tardis.obj",
    selection_box = {
        type = "fixed",
        fixed = {
            { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 },
        },
    },
    collision_box = {
        type = "fixed",
        fixed = {
            { 0.48, -0.5,-0.5,  0.5,  1.5, 0.5},
            {-0.5 , -0.5, 0.48, 0.48, 1.5, 0.5},
            {-0.5,  -0.5,-0.5 ,-0.48, 1.5, 0.5},
            { -0.7,-0.6,-0.7,0.7,-0.48, 0.7},
        }
    },
    sunlight_propagates = true,
    groups = {not_in_creative_inventory = 1},
    use_texture_alpha = "clip",
    diggable = false,
    on_timer = function(pos)
        local objs = minetest.get_objects_inside_radius(pos, 0.9)
        --[[if #objs ~= 0 then
            _tardis.tools.log("Found "..tostring(#objs).." # of objects, at "..minetest.pos_to_string(pos))
        end]]
        if objs[1] == nil then return true else
            if objs[1]:is_player() then -- Check if it's a player or if it's an entity (mob)
            
                local pmeta = objs[1]:get_meta()
                local meta = minetest.get_meta(pos)
                local id = meta:get_string("id")
                local user = _tardis.get_user(id)
                if user.version == nil then
                    _tardis.tools.log("Registering door before after failed to get user '"..id.."'.")
                    return true
                end
                local go_pos = user.out_pos
                
                -- Change this based on the tardis's exit direction (rather than hard coded for only one dir)
                local look = 0
                if user.dest_dir == 0 then -- N
                    go_pos.z = go_pos.z+1
                    look = 0
                elseif user.dest_dir == 2 then -- S
                    go_pos.z = go_pos.z-1
                    look = 180
                elseif user.dest_dir == 1 then -- W
                    go_pos.x = go_pos.x-1
                    look = 90
                elseif user.dest_dir == 3 then -- E
                    go_pos.x = go_pos.x+1
                    look = 270
                end
                objs[1]:set_pos(go_pos)
                objs[1]:set_look_horizontal( _tardis.tools.deg2rad(look) )
                objs[1]:set_look_vertical( _tardis.tools.deg2rad(0) )
                _tardis.tools.log("Player '"..objs[1]:get_player_name().."' exits tardis located at "..minetest.pos_to_string(go_pos))
                
                -- Deal damage to the player because they left while still in the vortex
                --[[if pmeta:get_string("vortex") == "yes" then 
                    go_pos.z = go_pos.z-2
                    objs[1]:set_pos(go_pos)
                    objs[1]:set_hp(0) 
                end]]

                -- Setup the exterior to change skins and restart the door timer
                minetest.after(1, function()
                    local meta = minetest.get_meta(pos)
                    local id = meta:get_string("id")
                    local user = _tardis.get_user(id)
                    if user.version == nil then
                        _tardis.tools.log("Registering door at after failed to get user '"..id.."'.")
                        return
                    end
                    local go_pos = user.out_pos
                    local look = user.exterior_theme
                    minetest.set_node(go_pos, {name=look, param1=user.dest_dir, param2=user.dest_dir}) -- Set exterior skin
                    local ometa = minetest.get_meta(go_pos)
                    ometa:set_string("id", id)
                    local timer = minetest.get_node_timer(go_pos)
                    timer:start(0.2) -- Restart door timer
                end)
            else -- entity not player
                local meta = minetest.get_meta(pos)
                local id = meta:get_string("id")
                local user = _tardis.get_user(id)
                if user.version == nil then
                    _tardis.tools.log("Registering door at entity not player failed to get user '"..id.."'.")
                    return true
                end
                local go_pos = user.out_pos
                -- Change this based on the tardis's exit direction (rather than hard coded for only one dir)
                --go_pos.z = go_pos.z-1
                if user.dest_dir == 0 then -- N
                    go_pos.z = go_pos.z+1
                elseif user.dest_dir == 2 then -- S
                    go_pos.z = go_pos.z-1
                elseif user.dest_dir == 1 then -- W
                    go_pos.x = go_pos.x-1
                elseif user.dest_dir == 3 then -- E
                    go_pos.x = go_pos.x+1
                end
                objs[1]:set_pos(go_pos)
                _tardis.tools.log("Entity exits tardis located at "..minetest.pos_to_string(go_pos))
            end
        end
        return true
    end,
})

--fix door timer
minetest.register_lbm({
	name = "tardis:fix_door_timers",
	nodenames = {"tardis:interior_door"},
	action = function(pos, node)
		local timer = minetest.get_node_timer(pos)
        if timer:is_started() ~= true then -- Start it only if it's needed
            _tardis.tools.log("Restarted door timer at "..minetest.pos_to_string(pos))
		    timer:start(0.2)
        end
	end
})
