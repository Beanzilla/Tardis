# Tardis > API Docs

## Overall:

What can we do with the public API:

* Set and retrieve waypoints
* Query Tardis power levels
* Query if a user is allowed on board a particular Tardis (I.E. will security measures be activated or are they free to enter and do as they please)
* Set and retrieve the current destination position of the Tardis (This feature is limited by the Tardis, one must provide a valid name for verification they can pilot said Tardis)
* Query how many Tardises are made
* Query membership status of a Tardis

> Some of the private API even calls the very same public API

What to expect in return:

* Success (bool) if the operation or action was successfully performed/queried.
* Errmsg (string) `if !success then a message of what failed or why else an empty string end`.
* Value (any) `if !success then value=nil else value=any end`, can be used for queries which ask for information. (Will be specific for particular calls/functions)

Will return `{success=true, errmsg="", value=nil}` on success, else `{success=false, errmsg="%s", value=nil}` where %s is a error message.

## Waypoints

> There is a tardis.waypoints namespace (For better docs I won't abbreviate it, so it's like it would be as you a user of the mod API would call it)

### tardis.waypoints.set(user_name, waypoint_name, waypoint_pos, waypoint_dir)

This **will** overwrite existing waypoint by given waypoint_name. (This means it's pos will now be waypoint_pos, it's dir will now be waypoint_dir)

> If the waypoint_name doesn't exist one will be created with such name. (errmsg will indicate if it created or overwrote a waypoint, just incase you wanted to check for that, after the fact though)
> Best to use tardis.waypoints.get() first to check if that waypoint exists (then use set)

```lua
-- Form a temporary value to store the results
local rc = tardis.waypoints.set("ApolloX", "My Home", vector.new(200, 2000, 250), 0) -- Facing North, +Z
if !rc.success then -- If we failed, let's message the player the error message
    minetest.chat_send_player("ApolloX", rc.errmsg)
end
```

### tardis.waypoints.get(user_name, waypoint_name)

This checks if a waypoint by waypoint_name exists, if so return it's position and direction, else returns `success=false` code.

```lua
-- Form a temp value to store the results
local rc = tardis.waypoints.get("ApolloX", "My Home")
if !rc.success then -- We failed, let's let the player know the error
    minetest.chat_send_player("ApolloX", rc.errmsg)
else
    -- We passed, we now have rc.value containing a table of pos and dir
    -- In this example we will send the player a message of the waypoint's position (minetest formated) and a number of the direction
    -- I will be providing public access to the private utility which can take a direction and convert it to text.
    minetest.chat_send_player("ApolloX", "Pos="..minetest.pos_to_string(rc.pos)..", Dir="..tostring(rc.dir))
end
```

### tardis.waypoints.remove(user_name, waypoint_name)

First checks if it exists, if so then it removes it. (now it no longer exists)

> Returns if it removed it or if the remove failed (I.E. because it doesn't exist)

```lua
-- Form a temp value to store the results
local rc = tardis.waypoints.remove("ApolloX", "My Home")
if !rc.success then -- We failed, let's let the player know the error
    minetest.chat_send_player("ApolloX", rc.errmsg)
end
```

## Power

> There is a tardis.power_check namespace (For better docs I won't abbreviate it, so it's like it would be as you a user of the mod API would call it)

You will note, currently the public API does not support adding power capacity (increasing max capacity) or power generation or even alter current power levels (current power).

In future versions I may open this up to the public API (for now it will remain private API calls)

### tardis.power_check.get(user_name)

This returns the current power level. (Failure really isn't possible but can happen if asking for a user who doesn't have a tardis, thus no tardis data)

```lua
-- Form a temp value to store the results
local rc = tardis.power_check.get("ApolloX")
if !rc.success then -- We failed, let's let the player know the error
    minetest.chat_send_player("ApolloX", rc.errmsg)
else
    -- Now to access what we got we'd use rc.value
end
```

### tardis.power_check.get_max(user_name)

This returns the max power level able to be stored. (Failure really isn't possible but can happen if asking for a user who doesn't have a tardis, thus no tardis data)

```lua
-- Form a temp value to store the results
local rc = tardis.power_check.get_max("ApolloX")
if !rc.success then -- We failed, let's let the player know the error
    minetest.chat_send_player("ApolloX", rc.errmsg)
else
    -- Now to access what we got we'd use rc.value
end
```

### tardis.power_check.get_perc(user_name)

Returns the percent of power remaining. (Failure really isn't possible but can happen if asking for a user who doesn't have a tardis, thus no tardis data)

```lua
-- Form a temp value to store the results
local rc = tardis.power_check.get_perc("ApolloX")
if !rc.success then -- We failed, let's let the player know the error
    minetest.chat_send_player("ApolloX", rc.errmsg)
else
    -- Now to access what we got we'd use rc.value
end
```

## Memberships

A Tardis can only have one owner, but many companions (can interact with chests and other basic machines, but no Tardis consoles/nodes (but allows Tardis Chest access)),
 and many pilots (can interact with all companion's can, and can also interact with Tardis consoles/nodes).

Thus membership refers to either owner/companion or pilot. (And will be indicated by a basic ENUM of "NONE", "OWNER", "COMPANION" or "PILOT" in value
 return results, where "NONE" means they are not allowed on that Tardis)

> There is a tardis.memberships namespace  (For better docs I won't abbreviate it, so it's like it would be as you a user of the mod API would call it)

Currently the only call you can do is get one individual user's status (not able to get list and not able to change memberships promote/demote etc.)

### tardis.memberships.get(user_name, my_name)

Given the name of the Tardis owner and the name to search for, looks in companions and then in pilots. (First checks if it's the owner, if so stops there)

```lua
local rc = {}

rc = tardis.memberships.get("ApolloX", "ApolloX")
if !rc.success then -- Report error
    minetest.chat_send_player("ApolloX", rc.errmsg)
else
    -- Now we can check if the given via rc.value is "NONE", "OWNER", "COMPANION" or "PILOT"
    -- In this case it would be "OWNER" since I am the owner (it wouldn't iterate over companions or pilots it would jump out because it's the owner)
end

rc = tardis.memberships.get("ApolloX", "AnotherUser")
if !rc.success then -- Report error
    -- I'm choosing to send the message to the one possibly asking membership status
    minetest.chat_send_player("AnotherUser", rc.errmsg)
else
    -- Now we can check if the given via rc.value is "NONE", "OWNER", "COMPANION" or "PILOT"
    -- If it was a companion it would stop iterating over companions once it found them, or if they are a pilot then again it would iterate over it till 
    -- they were found.
    -- Note: If they were not the owner, companion or pilot it iterates over everything then reports back "NONE" to indicate that they are not a part of 
    -- that tardis.
end
```
