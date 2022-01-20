
local lighting = {}

lighting.on_punch = function (pos, node, puncher, pointed)
    --_tardis.tools.log(minetest.serialize(node))
    local name = node.name
    local param1 = node.param1
    local param2 = node.param2
    if name:find("tardis:light") then
        if name:find("off") then
            minetest.swap_node(pos, {name = "tardis:light_on", param1 = param1, param2 = param2})
        else
            minetest.swap_node(pos, {name = "tardis:light_off", param1 = param1, param2 = param2})
        end
    end
end

minetest.register_node("tardis:light_off", {
    short_description = "Tardis Light",
    description = "Tardis Light (Off)\nPunch to toggle ON.",
    inventory_image = "tardis_light_off.png",
    drawtype = "signlike",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    light_source = 1,
    paramtype2 = "wallmounted",
    selection_box = { type = "wallmounted" },
    drop = "tardis:light_off",
    tiles = {"tardis_light_off.png"},
    groups = {dig_immediate=3},
    on_punch = lighting.on_punch
})
minetest.register_node("tardis:light_on", {
    short_description = "Tardis Light",
    description = "Tardis Light (On)\nPunch to toggle OFF.",
    inventory_image = "tardis_light_on.png",
    drawtype = "signlike",
    paramtype = "light",
    walkable = false,
    sunlight_propagates = true,
    light_source = minetest.LIGHT_MAX,
    paramtype2 = "wallmounted",
    selection_box = { type = "wallmounted" },
    drop = "tardis:light_off",
    tiles = {"tardis_light_on.png"},
    groups = {dig_immediate=3},
    on_punch = lighting.on_punch
})
