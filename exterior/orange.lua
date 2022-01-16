
minetest.register_node("tardis:tardis_orange", {
    description = "Tardis",
    tiles = {"tardis_orange.png"},
    drawtype = "mesh",
    mesh = "tardis_2.obj",
    selection_box = {type = "fixed", fixed = { { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 } }},
    collision_box = {type = "fixed", fixed = { { 0.48, -0.5,-0.5,  0.5,  1.5, 0.5}, {-0.5 , -0.5, 0.48, 0.48, 1.5, 0.5}, {-0.5,  -0.5,-0.5 ,-0.48, 1.5, 0.5}, { -0.8,-0.6,-0.8,0.8,-0.48, 0.8} }},
    light_source = 10,
    groups = {not_in_creative_inventory = 1, tardis = 1},
    diggable = false,
    after_place_node = _tardis.exterior.tardis_on_place,
    on_timer = _tardis.exterior.tardis_timer
})
minetest.register_node("tardis:tardis_orange_locked", {
    description = "Tardis",
    tiles = {"tardis_orange.png"},
    drawtype = "mesh",
    mesh = "tardis_2.obj",
    selection_box = {type = "fixed", fixed = { { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 } }},
    collision_box = {type = "fixed", fixed = { { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 } }},
    light_source = 10,
    groups = {not_in_creative_inventory = 1, tardis_locked = 1},
    diggable = false
})
