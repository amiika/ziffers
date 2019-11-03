load "~/ziffers/ziffers.rb"

use_synth :piano

zloop :moonlight, "h 07  |: (-3 0 2) :4| -16 |: (-3 0 2) :4| -25 |: (-2 0 2) :| -43 |: (-2 &1 3) :| -34 (-3 -#1 3) (-3 0 2) -34 (-3 0 #1) (-4 -1 1)",
  key: :cs4, scale: :minor, release: 4, sustain: 3, attack: 0.2, decay: 1,
  chord_key: :cs2, chord_sleep: 0, chord_release: 2, chord_decay: 2