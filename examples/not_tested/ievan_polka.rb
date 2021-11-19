require "~/ziffers/ziffers.rb"

ievanpolka = \
  "|:q0 e0 0 q0 1| q2 0 0 2 |;q1 _6 6 ^1 |q2 0 h0 ; q. 4 e3 q2 1|q2 0 h0:|"\
  "|:q4 e4 4 q3 2|q1 _6 6 ^1|;q3 e3 3 q2 1|q2 0 0 2;q3 e3 3 q2 1|q2 0 h0:|"

n = zparse ievanpolka, key:"g", scale:"minor"
notes = zparams(n, :note)
pitch = zparams(n, :pitch)
notes = [notes,pitch].transpose.map {|x| x.reduce(:+)}
durations = zparams(n, :sleep)

with_synth :mod_tri do
  play_pattern_timed notes, durations, release: 0.1
end
