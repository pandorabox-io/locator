

local update_formspec = function(meta)
	local inv = meta:get_inventory()

	meta:set_string("formspec", "size[8,3;]" ..
		-- col 1
		"button_exit[0,1;8,1;sweep;Radar sweep]" ..
		"")
end

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

local show_radar = function(pos, player)
	local name = player:get_player_name()
	local hud_data = hud[name]

	if hud_data then
		-- already active hud
		return
	end

	hud_data = {}

	for i,beacon in pairs(locator.beacons) do
		local distance = vector.distance(pos, beacon.pos)
		if distance < beacon.range then
			-- in range
			local id = player:hud_add({
				hud_elem_type = "waypoint",
				name = "Beacon: " .. beacon.name,
				text = "m",
				number = 0x00FF00,
				world_pos = beacon.pos
			})
			
			table.insert(hud_data, id)
		end
	end

	hud[name] = hud_data;

	minetest.after(10, function()
		clear_radar(name)
	end)

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
	sounds = default.node_sound_glass_defaults(),

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		update_formspec(meta)
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		if fields.sweep then
			show_radar(pos, sender)
		end
	end
})


minetest.register_craft({
	output = "locator:radar",
	recipe = {
		{"default:glass", "locator:beacon_base", "default:glass"},
		{"locator:beacon_base", "locator:beacon_base", "locator:beacon_base"},
		{"default:glass", "locator:beacon_base", "default:glass"}
	}
})

