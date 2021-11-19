load "~/ziffers/ziffers.rb"


p = range(0.01,1.0, step: 0.01).mirror

use_synth :piano

z1 "q 1 2 3 4"
z2 "q 1 2 3 4", sync: :z1, phase: p
