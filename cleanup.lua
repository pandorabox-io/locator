
function do_cleanup()
  for _, player in ipairs(minetest.get_connected_players()) do
    -- TODO: cleanup
  end

  minetest.after(10, do_cleanup)
end

minetest.after(10, do_cleanup)
