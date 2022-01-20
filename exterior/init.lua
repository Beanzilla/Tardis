
local exterior = {}
exterior.on_place = function(pos, placer, itemstack, pointed_thing)
	if placer:get_player_name() == "" then return else
		local meta = minetest.get_meta(pos)
		local name = placer:get_player_name()
		local timer = minetest.get_node_timer(pos)
        local user = _tardis.get_user(name)
		if user.version == nil then
            user = _tardis.make_new_user(name)
            user.out_pos = vector.new(pos.x, pos.y, pos.z) -- Prev will still record 0, 0, 0 (at least until first jump into dematerialzation)
			pos.y = pos.y-300
			minetest.place_schematic(pos, _tardis.MODPATH .. DIR_DELIM .. "schems" .. DIR_DELIM .. "interior_console_room.mts")
			pos.y = pos.y+1
			pos.x = pos.x+7
			pos.z = pos.z+16
			local node = minetest.get_node_or_nil(vector.new(pos.x, pos.y, pos.z))
			if node ~= nil then
				_tardis.tools.log("Pos: "..minetest.pos_to_string(pos).." Node: "..node.name)
			end
			local ometa = minetest.get_meta(pos)
			local otimer = minetest.get_node_timer(pos)
			otimer:start(0.2) --start door timer (in case it doesn't start on construct)
			ometa:set_string("id", name) --set door id
			meta:set_string("id", name) -- set exterior id
            user.in_pos = vector.new(pos.x, pos.y, pos.z)
            user.validation = true
			 -- Gets the opposite dir (the one the user should enter)
			 -- Then sets the param2/facing
			user.dest_dir = _tardis.tools.toParam2( _tardis.tools.flip_dir( _tardis.tools.rad2deg( placer:get_look_horizontal() ) ) )
			_tardis.tools.log("Param2="..tostring(user.dest_dir))
			local myself = minetest.get_node_or_nil(user.out_pos)
			if myself ~= nil and myself.param2 ~= user.dest_dir then
				user.exterior_skins = myself.name -- Update it so our exterior is by default what ever tardis was placed
				minetest.swap_node(user.out_pos, {name=myself.name, param1=user.dest_dir, param2=user.dest_dir}) -- Attempt to replace ourselves
			end
			timer:start(0.2) -- Start tardis timer
            _tardis.save_user(name, user)
		else
            minetest.set_node(pos, {name = "air"})
            minetest.add_item(pos, itemstack)
			minetest.chat_send_player(name, "You can only have 1 Tardis.")
        end
	end
end

exterior.tardis_timer = function(pos)
	local objs = minetest.get_objects_inside_radius(pos, 0.9)
	if objs[1] == nil then return true else
		if objs[1]:is_player() then
			local meta = minetest.get_meta(pos)
			local pmeta = objs[1]:get_meta()
			local id = meta:get_string("id")
            local user = _tardis.get_user(id)
            local go_pos = user.in_pos or nil
            if go_pos == nil then return true end
			go_pos.z = go_pos.z-1
			objs[1]:set_look_horizontal( math.rad( 180 ))
			objs[1]:set_look_vertical( math.rad( 0 ))
			objs[1]:set_pos(go_pos)
			_tardis.tools.log("Player '"..objs[1]:get_player_name().."' enters tardis located at "..minetest.pos_to_string(go_pos))
			pmeta:set_string("id", id)
		else
			local meta = minetest.get_meta(pos)
			local id = meta:get_string("id")
			local user = _tardis.get_user(id)
            local go_pos = user.in_pos or nil
            if go_pos == nil then return true end
			go_pos.z = go_pos.z-1
			objs[1]:set_pos(go_pos)
			_tardis.tools.log("Entity enters tardis located at "..minetest.pos_to_string(go_pos))
		end
	end
	return true
end

-- Our basic tardis pair, typically used for colors
exterior.make_series = function (item)
	local locked = item .. "_locked"
	minetest.register_node("tardis:tardis_"..item, {
		description = "Tardis",
		tiles = {"tardis_".. item ..".png"},
		drawtype = "mesh",
		paramtype2 = "facedir",
		mesh = "tardis.obj",
		selection_box = {type = "fixed", fixed = { { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 } }},
		collision_box = {type = "fixed", fixed = { { 0.48, -0.5,-0.5,  0.5,  1.5, 0.5}, {-0.5 , -0.5, 0.48, 0.48, 1.5, 0.5}, {-0.5,  -0.5,-0.5 ,-0.48, 1.5, 0.5}, { -0.8,-0.6,-0.8,0.8,-0.48, 0.8} }},
		light_source = 10,
		groups = {not_in_creative_inventory = 1, tardis = 1},
		use_texture_alpha = "clip",
		after_place_node = exterior.on_place,
		diggable = false,
		on_timer = exterior.tardis_timer
	})
	minetest.register_node("tardis:tardis_"..locked, {
		description = "Tardis",
		tiles = {"tardis_".. item ..".png"},
		drawtype = "mesh",
		paramtype2 = "facedir",
		mesh = "tardis.obj",
		selection_box = {type = "fixed", fixed = { { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 } }},
		collision_box = {type = "fixed", fixed = { { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 } }},
		light_source = 10,
		groups = {not_in_creative_inventory = 1, tardis_locked = 1},
		use_texture_alpha = "clip",
		diggable = false
	})
end

-- Slightly different than above, removes the requiement of the tiles being from our mod
exterior.make_raw = function (item, img)
	local locked = item .. "_locked"
	minetest.register_node("tardis:tardis_"..item, {
		description = "Tardis",
		tiles = {img ..".png"},
		drawtype = "nodebox",
		--mesh = "tardis.obj",
		paramtype2 = "facedir",
		node_box = {type = "fixed", fixed = { { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 } }},
		selection_box = {type = "fixed", fixed = { { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 } }},
		collision_box = {type = "fixed", fixed = { { 0.48, -0.5,-0.5,  0.5,  1.5, 0.5}, {-0.5 , -0.5, 0.48, 0.48, 1.5, 0.5}, {-0.5,  -0.5,-0.5 ,-0.48, 1.5, 0.5}, { -0.8,-0.6,-0.8,0.8,-0.48, 0.8} }},
		light_source = 10,
		groups = {not_in_creative_inventory = 1, tardis = 1},
		use_texture_alpha = "clip",
		after_place_node = exterior.on_place,
		diggable = false,
		on_timer = exterior.tardis_timer
	})
	minetest.register_node("tardis:tardis_"..locked, {
		description = "Tardis",
		tiles = {img ..".png"},
		drawtype = "nodebox",
		--mesh = "tardis.obj",
		paramtype2 = "facedir",
		node_box = {type = "fixed", fixed = { { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 } }},
		selection_box = {type = "fixed", fixed = { { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 } }},
		collision_box = {type = "fixed", fixed = { { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 } }},
		light_source = 10,
		groups = {not_in_creative_inventory = 1, tardis_locked = 1},
		use_texture_alpha = "clip",
		diggable = false
	})
end

-- Different in aspect as everything is manually defined here
exterior.make_block = function (item, img, light_lvl)
	if light_lvl == nil then
		light_lvl = 10
	end
	local locked = item .. "_locked"
	minetest.register_node("tardis:tardis_"..item, {
		description = "Tardis",
		tiles = {img .. ".png"},
		drawtype = "nodebox",
		paramtype2 = "facedir",
		node_box = {type = "fixed", fixed = { { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 } }},
		selection_box = {type = "fixed", fixed = { { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 } }},
		collision_box = {type = "fixed", fixed = { { 0.48, -0.5,-0.5,  0.5,  1.5, 0.5}, {-0.5 , -0.5, 0.48, 0.48, 1.5, 0.5}, {-0.5,  -0.5,-0.5 ,-0.48, 1.5, 0.5}, { -0.8,-0.6,-0.8,0.8,-0.48, 0.8} }},
		light_source = light_lvl,
		groups = {not_in_creative_inventory = 1, tardis = 1},
		use_texture_alpha = "clip",
		after_place_node = exterior.on_place,
		diggable = false,
		on_timer = exterior.tardis_timer
	})
	minetest.register_node("tardis:tardis_"..locked, {
		description = "Tardis",
		tiles = {img .. ".png"},
		drawtype = "nodebox",
		paramtype2 = "facedir",
		node_box = {type = "fixed", fixed = { { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 } }},
		selection_box = {type = "fixed", fixed = { { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 } }},
		collision_box = {type = "fixed", fixed = { { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 } }},
		light_source = light_lvl,
		groups = {not_in_creative_inventory = 1,  tardis_locked = 1},
		use_texture_alpha = "clip",
		diggable = false
	})
end

-- Execute each node def (for both regular and the locked varient)
-- See dynamic_textures.lua for a more detailed list of skin choices
exterior.make_series("blue")
exterior.make_series("pink")
exterior.make_series("yellow")
exterior.make_series("brown")
exterior.make_series("red")
exterior.make_series("green")
exterior.make_series("cyan")
exterior.make_series("magenta")
exterior.make_series("orange")
exterior.make_series("silver")
exterior.make_series("clear")
exterior.make_series("old")
exterior.make_series("cool")
exterior.make_series("soda")
exterior.make_series("funky")
exterior.make_raw("stone", "default_stone")
exterior.make_raw("leave", "default_leaves")
exterior.make_block("empty", "empty", 2) -- Cloaked
