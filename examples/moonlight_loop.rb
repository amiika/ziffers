load "~/ziffers/ziffers.rb"

use_synth :piano
use_bpm 100

zloop :moonlight, "h 07  [: (-3 0 2) :4] -16 [: (-3 0 2) :4] -25 [: (-2 0 2) :] -43 [: (-2 b1 3) :] -34 (-3 #-1 3) (-3 0 2) -34 (-3 0 #1) (-4 -1 1)",
  key: :cs4, scale: :minor, release: 4, sustain: 3, decay: 1,
  chord_key: :cs2
