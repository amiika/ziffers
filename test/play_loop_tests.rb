
def loop_tests
  z1 "0", stop: 1
  z2 ->(){rrand_i(1,4)}, stop: 1
  z3 (0..Float::INFINITY).lazy.collect{|n|n.to_s(2).split('').count('1')%7}, rhythm:spread(7,9), stop: 1
  z4 pi.take(1), scale: :kumoi, synth: :tb303, rhythm: 0.125, cutoff: tweak(:sine,60,100,10).reflect, stop: 1
  z5 "q0", rules: {"q"=>"e", "e"=>"q"}, stop: 1
end

loop_tests
