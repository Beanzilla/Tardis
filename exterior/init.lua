
_tardis.exterior = {}
_tardis.exterior.on_place = function(pos, placer, itemstack, pointed_thing)
	if placer:get_player_name() == "" then return else
		local meta = minetest.get_meta(pos)
		local name = placer:get_player_name()
		local timer = minetest.get_node_timer(pos)
        local user = _tardis.get_user(name)
		if !_tardis.tools.tableContainsValue(user, "version") then
            user = _tardis.make_new_user(name)
            user.out_pos = pos -- Prev will still record 0, 0, 0 (at least untill first jump into dematerialzation)
			pos.y = pos.y-300
			minetest.place_schematic(pos, _tardis.MODPATH .. DIR_DELIM .. "schems" .. DIR_DELIM .. "console_room.mts")
			pos.y = pos.y+2
			pos.x = pos.x+7
			pos.z = pos.z+16
			local ometa = minetest.get_meta(pos)
			local otimer = minetest.get_node_timer(pos)
			otimer:start(0.2) --start door timer (in case it doesn't start on construct)
			ometa:set_string("id", name) --set door id
			meta:set_string("id", name) -- set exterior id
            user.in_pos = pos
            user.validation = true
			timer:start(0.2)
            _tardis.save_user(name, user)
		else
            minetest.set_node(pos, {name = "air"})
            minetest.add_item(pos, _tardis.exterior_skins.colored.blue)
        end
	end
end

_tardis.exterior.tardis_timer = function(pos)
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
			pmeta:set_string("id", id)
		else
			local meta = minetest.get_meta(pos)
			local id = meta:get_string("id")
			local user = _tardis.get_user(id)
            local go_pos = user.in_pos or nil
            if go_pos == nil then return true end
			go_pos.z = go_pos.z-2
			objs[1]:set_pos(go_pos)
		end
	end
	return true
end

-- Execute each node def (for both regular and the locked varient)
-- See dynamic_textures.lua for a more detailed list of skin choices
_tardis.do_src("exterior", "blue") -- "tardis:tardis"
_tardis.do_src("exterior", "pink")
_tardis.do_src("exterior", "yellow")
_tardis.do_src("exterior", "old")
_tardis.do_src("exterior", "stone")
_tardis.do_src("exterior", "empty") -- Cloaked
_tardis.do_src("exterior", "cool")
_tardis.do_src("exterior", "leaves")
_tardis.do_src("exterior", "soda")
_tardis.do_src("exterior", "funky")
_tardis.do_src("exterior", "brown")
_tardis.do_src("exterior", "red")
_tardis.do_src("exterior", "green")
_tardis.do_src("exterior", "cyan")
_tardis.do_src("exterior", "magenta")
_tardis.do_src("exterior", "orange")
_tardis.do_src("exterior", "silver")
_tardis.do_src("exterior", "clear")
