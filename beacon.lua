
local update_formspec = function(meta)
	local inv = meta:get_inventory()

	local active = meta:get_int("active") == 1
	local state = "Inactive"

	if active then
		state = "Active"
	end

	local name = meta:get_string("name")
	meta:set_string("infotext", "Locator: " .. name .. " (" .. state .. ")")

	meta:set_string("formspec", "size[8,3;]" ..
		-- col 1
		"field[0,1.5;4,1;name;Name;" .. name .. "]" ..
		"button_exit[4,1;4,1;save;Save]" ..
		"button_exit[0,2;8,1;toggle;Toggle]" ..
		"")
end

-- base beacon
minetest.register_node("locator:beacon_base", {
	description = "Locator beacon base",
	tiles = {
		"locator_beacon_base.png",
		"locator_beacon_base.png",
		"locator_beacon_base.png",
		"locator_beacon_base.png",
		"locator_beacon_base.png",
		"locator_beacon_base.png",
	},
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults()
})

minetest.register_craft({
	output = "locator:beacon_base",
	recipe = {
		{"default:glass", "default:mese", "default:glass"},
		{"default:diamondblock", "default:mese", "default:diamondblock"},
		{"default:glass", "default:mese", "default:glass"}
	}
})

-- level/range register beacon
local register_beacon = function(level, range, ingredient)

	minetest.register_node("locator:beacon_" .. level, {
		description = "Locator beacon, level: " .. level .. ", range: " .. range,
		tiles = {
			"locator_beacon_level" .. level .. ".png",
			"locator_beacon_level" .. level .. ".png",
			"locator_beacon_level" .. level .. ".png",
			"locator_beacon_level" .. level .. ".png",
			"locator_beacon_level" .. level .. ".png",
			"locator_beacon_level" .. level .. ".png"
		},
		groups = {cracky=3,oddly_breakable_by_hand=3},
		sounds = default.node_sound_glass_defaults(),

		after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos)
			meta:set_string("owner", placer:get_player_name() or "")
		end,

		after_dig_node = function(pos)
			locator.remove_beacon(pos)
		end,

		on_construct = function(pos)
			local meta = minetest.get_meta(pos)

			meta:set_string("name", "<unconfigured>")
			meta:set_int("range", range)
			meta:set_int("active", 0)

			update_formspec(meta)
		end,

		on_receive_fields = function(pos, formname, fields, sender)
			local meta = minetest.get_meta(pos)
			local playername = sender:get_player_name()

			if playername == meta:get_string("owner") then
				-- owner
				if fields.save then

					local name = fields.name
					meta:set_string("name", fields.name)


				end

				if fields.toggle then
					if meta:get_int("active") == 1 then
						meta:set_int("active", 0)
					else
						meta:set_int("active", 1)
					end
				end

			else
				-- non-owner
			end


			update_formspec(meta)
			locator.update_beacon(pos, meta)
		end


	})

	minetest.register_craft({
		output = "locator:beacon_" .. level,
		recipe = {
			{"default:glass", "default:mese", "default:glass"},
			{ingredient, ingredient, ingredient},
			{"default:glass", "default:mese", "default:glass"}
		}
	})

end


register_beacon(1, 500, "locator:beacon_base") -- short range
register_beacon(2, 5000, "locator:beacon_1") -- mid range
register_beacon(3, 30000, "locator:beacon_2") -- long range

