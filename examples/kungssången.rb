require "~/ziffers/ziffers.rb"

use_bpm 115

kungssangen = \
  "|:h5 | 3 5 8     | .7 q6 h5 t0 h5 | ^ 4 3 2 1 _ | .3 q2 h2   |"\
  "| h8 | 7 6 5 q67 | .h8 q0 h5     :|:.7 ^q1 h2 _5| ^.3 q2 h1 _|"\
  "| h8 |.7 q7  h86 | .5 q4 h3 t0 h5 |.7 ^q1 h2 _5| ^ 3 2 1 _  |"\
  "| h7 |.6 ^ q2 h1_7 | .h8 0 :|"

zplay kungssangen, key: :f, scale: :aeolian
