
seq = [->n{n+2},->n{n-2},->n{n+rrand_i(-8,1)},->n{n/2}].ring.reflect

1.upto(50) do |m|
  zplay seq.tick(:note).(m).to_s
end
