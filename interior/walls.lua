
-- Light
minetest.register_node("tardis:light_wall", {
    description = "Tardis Wall (non-craftable)",
    tiles = {"tardis_wall.png"},
    diggable = false,
    groups = { not_in_creative_inventory = 1},
})
minetest.register_node("tardis:light_wall_craftable", {
    description = "Tardis Wall",
    tiles = {"tardis_wall.png"},
    groups = {cracky = 1},
})

-- Dark
minetest.register_node("tardis:dark_wall", {
    description = "Tardis Wall (non-craftable)",
    tiles = {"tardis_wall_dark.png"},
    diggable = false,
    groups = { not_in_creative_inventory = 1},
})
minetest.register_node("tardis:dark_wall_craftable", {
    description = "Tardis Wall",
    tiles = {"tardis_wall_dark.png"},
    groups = {cracky = 1},
})
