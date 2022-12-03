load "~/ziffers/ziffers.rb"

use_bpm 300

ievanpolka = \
  "[:q 0 e 0 0 q 0 1 | q 2 0 0 2    |  <(q1 _ 6 6 ^1 |q2 0 h0) (q. 4 e3 q 2 1|q 2 0 h0)> :]"\
  "[:q 4 e 4 4 q 3 2 | q 1 _ 6 6 ^1 | <(q3 e3 3 q2 1|q2 0 0 2) (q3 e 3 3 q 2 1|q 2 0 h0)> :]"

n = zparse ievanpolka, key:"g", scale:"minor"
notes = zparams(n, :note)
durations = zparams(n, :beats)

with_synth :mod_tri do
  play_pattern_timed notes, durations, release: 0.1
end
