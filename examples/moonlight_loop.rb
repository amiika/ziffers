load "~/ziffers/ziffers.rb"

use_synth :piano

zloop :moonlight, "h 18  |: (-3 1 3) :4| -17 |: (-3 1 3) :4| -26 |: (-2 1 3) :| -44 |: (-2 &2 4) :| -35 (-3 -#1 4) (-3 1 3) -35 (-3 1 #2) (-4 -1 2)",
  groups: true, key: :cs4, scale: :minor, release: 4, sustain: 3, attack: 0.2, decay: 1,
  chord_key: :cs2, chord_sleep: 0, chord_release: 2, chord_decay: 2