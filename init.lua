
local MP = minetest.get_modpath("locator")

locator = {
	beacons = {}
}

dofile(MP.."/beacon.lua")
dofile(MP.."/functions.lua")
dofile(MP.."/radar.lua")

print("[OK] Locator")
