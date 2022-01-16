
-- Data storage for what skin is what texture
_tardis.exterior_skins = {
    old = "tardis:tardis_old", -- Taridis_New's default
    old_locked = "tardis:tardis_old_locked",
    cool = "tardis:tardis_cool",
    cool_locked = "tardis:tardis_cool_locked",
    funky = "tardis:tardis_funky",
    funky_locked = "tardis:tardis_funky_locked",
    soda = "tardis:tardis_soda",
    soda_locked = "tardis:tardis_soda_locked",
    leave = "tardis:tardis_leave",
    leave_locked = "tardis:tardis_leave_locked",
    stone = "tardis:tardis_stone",
    stone_locked = "tardis:tardis_stone_locked",
    empty = "tardis:tardis_empty",
    empty_locked = "tardis:tardis_empty_locked",
    colored = { -- Just to seperate colored into unique categories
        yellow = "tardis:tardis_yellow",
        yellow_locked = "tardis:tardis_yellow_locked",
        pink = "tardis:tardis_pink",
        pink_locked = "tardis:tardis_pink_locked",
        blue = "tardis:tardis", -- Default used on make_new_user
        blue_locked = "tardis:tardis_locked",
        -- To complete the rainbow (of sorts)
        brown = "tardis:tardis_brown",
        brown_locked = "tardis:tardis_brown_locked",
        red = "tardis:tardis_red",
        red_locked = "tardis:tardis_red_locked",
        green = "tardis:tardis_green",
        green_locked = "tardis:tardis_green_locked",
        cyan = "tardis:tardis_cyan",
        cyan_locked = "tardis:tardis_cyan_locked",
        magenta = "tardis:tardis_magenta",
        magenta_locked = "tardis:tardis_magenta_locked",
        orange = "tardis:tardis_orange",
        orange_locked = "tardis:tardis_orange_locked",
        silver = "tardis:tardis_silver",
        silver_locked = "tardis:tardis_silver_locked",
    },
    clear = "tardis:tardis_clear",
    clear_locked = "tardis:tardis_clear_locked",
}

-- Aliases
_tardis.exterior_skins.leaves = _tardis.exterior_skins.leave
_tardis.exterior_skins.leaves_locked = _tardis.exterior_skins.leave_locked
_tardis.exterior_skins.cloaked = _tardis.exterior_skins.empty
_tardis.exterior_skins.cloaked_locked = _tardis.exterior_skins.empty_locked
_tardis.exterior_skins.colored.purple = _tardis.exterior_skins.colored.magenta
_tardis.exterior_skins.colored.purple_locked = _tardis.exterior_skins.colored.magenta_locked
_tardis.exterior_skins.colored.gray = _tardis.exterior_skins.colored.silver
_tardis.exterior_skins.colored.gray_locked = _tardis.exterior_skins.colored.silver_locked

-- Data storage for what skin is what texture (really not used for much except switching from dark theme to light theme)
_tardis.interior_skins = {
    dark = "tardis:dark_wall",
    light = "tardis:light_wall" -- Default used on make_new_user
}
