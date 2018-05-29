
local path = minetest.get_worldpath().."/locator_beacons.txt";

local load_beacons = function()
   local file = io.open( path, "r" );
   if( file ) then
      local data = file:read("*all");
      locator.beacons = minetest.deserialize( data );
      file:close();
   else
      print("[Mod locator] Warning: Savefile '"..tostring( path ).."' not found.");
   end
end

load_beacons()

local save_beacons = function()
   local file = io.open( path, "w" );
   if( file ) then
      file:write( minetest.serialize(locator.beacons) );
      file:close();
   else
      print("[Mod locator] Error: Savefile '"..tostring( path ).."' could not be written.");
   end
end

locator.update_beacon = function(pos, meta)
	local active = meta:get_int("active") == 1
	local name = meta:get_string("name")
	local range = meta:get_int("range")

	local found = false
	local data = { pos=pos, active=active, name=name, range=range }

	for i,beacon in pairs(locator.beacons) do
		if beacon.pos.x == pos.x and beacon.pos.y == pos.y and beacon.pos.z == pos.z then
			-- found
			locator.beacons[i] = data
			found = true
		end
	end

	if not found then
		-- new entry
		table.insert(locator.beacons, data)
	end

	save_beacons()

end

locator.remove_beacon = function(pos)
	for i,beacon in pairs(locator.beacons) do
		if beacon.pos.x == pos.x and beacon.pos.y == pos.y and beacon.pos.z == pos.z then
			-- found
			table.remove(locator.beacons, i)
			save_beacons()
			return
		end
	end
end