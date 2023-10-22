load "~/ziffers/examples/kircher.rb"

use_bpm 100

r = 1

use_synth :hollow
use_synth_defaults release: 2.0

live_loop :kircher do
  r = rand_i(2)
  rp = rand_i(2)
  print r
  m = get_cardset(3)[:cards][r][:p][rp]
  rh = get_cardset(4)[:cards][r][:r][rp]
  zthread m[1], rhythm: rh[1].map{|v|v/4}
  zthread m[2], rhythm: rh[2].map{|v|v/4}
  zthread m[3], rhythm: rh[3].map{|v|v/4}
  zplay m[0], rhythm: rh[0].map{|v|v/4}
end
