

local hud = {} -- playername -> {}

local clear_radar = function(playername)
	local hud_data = hud[playername]
	local player = minetest.get_player_by_name(playername)

	if not hud_data or not player or not player:is_player() then
		return
	end

	for _,id in pairs(hud_data) do
		player:hud_remove(id)
	end

	hud[playername] = nil
end

local format_pos = function(pos)
	return pos.x .. "/" .. pos.y .. "/" .. pos.z
end

local show_radar = function(pos, player)
	local name = player:get_player_name()
	local hud_data = hud[name]

	if hud_data then
		-- already active hud, clear stale data
		clear_radar(name)
	end

	hud_data = {}

	for i,beacon in pairs(locator.beacons) do
		local distance = vector.distance(pos, beacon.pos)
		if distance < beacon.range then
			-- in range
			local id = player:hud_add({
				hud_elem_type = "waypoint",
				name = "Beacon: " .. beacon.name .. ", " .. format_pos(beacon.pos),
				text = "m",
				number = 0x00FF00,
				world_pos = beacon.pos
			})
			
			table.insert(hud_data, id)
		end
	end

	hud[name] = hud_data;

end

-- locator radar
minetest.register_node("locator:radar", {
	description = "Locator radar",
	tiles = {
		"locator_radar.png",
		"locator_radar.png",
		"locator_radar.png",
		"locator_radar.png",
		"locator_radar.png",
		"locator_radar.png"
	},
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults()
})


minetest.register_craft({
	output = "locator:radar",
	recipe = {
		{"default:glass", "locator:beacon_base", "default:glass"},
		{"locator:beacon_base", "locator:beacon_base", "locator:beacon_base"},
		{"default:glass", "locator:beacon_base", "default:glass"}
	}
})

-- timeout check
local timer = 0
local radius = 8
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;

	-- check every 2 seconds if radar nearby
	if timer >= 2 then
		local players = minetest.get_connected_players()
		for i,player in pairs(players) do
			local pos = player:get_pos()
			local node = minetest.find_node_near(pos, radius, {"locator:radar"}, true)
			if node then
				show_radar(pos, player)
			else
				clear_radar(player:get_player_name())
			end
		end

		timer = 0
	end
end)

