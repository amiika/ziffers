require "~/ziffers/ziffers.rb"

r = lsystem "1.0", {"1.0"=>"0.25,0.5", "0.25"=>"0.75,0.75,0.5", "0.75"=>"0.25,1.0,0.125,0.125"}, 6
r = r.flatten.join.split(",").map(&:to_f).ring
print r
live_loop :drum do
  sample :bd_fat
  sleep 0.125
  sample :drum_cymbal_closed
  sleep r.tick
end
