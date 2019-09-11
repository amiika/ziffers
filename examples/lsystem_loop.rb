require "~/ziffers/ziffers.rb"

use_synth :chipbass

n = lsystem("q12e3456",{"1"=>"[2,4]","2"=>"[1,5]","3"=>"5","4"=>"3","5"=>"[1,3]"},10).ring

live_loop :p do
  sample :bd_tek
  zplay n.tick
end
