ievanpolka = \
  "@|:q1e11q12|q3113;q2-77+2|q31h1;q.5e4q32|q31h1:|"\
  " |:q5e55q43|q2-77+2;q4e44q32|q3113;q4e44q32|q31h1:|@"

n = zparse(ievanpolka,{key:"g", scale:"minor"})
notes = zparams(n, :note)
pitch = zparams(n, :pitch)
notes = [notes,pitch].transpose.map {|x| x.reduce(:+)}
durations = zparams(n, :sleep)

with_synth :mod_tri do
  play_pattern_timed notes, durations, release: 0.1
end