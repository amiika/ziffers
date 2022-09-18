load "~/ziffers/ziffers.rb"

Ziffers.debug

def test_generative

  # Generative syntax
  with_random_seed 2353 do
    a = zparse "[: q ? ? ? 0 ? ? ? (1,2) [6,7] (1,2) [6,7] (1,2) [6,7] (1,2) [6,[7 2,8,9 3,11]] :]"
    assert_equal(a.notes.length,30)
    a = zparse "([1,4,5,3],[(6,7),(6,[8,10,11]),(6,[9,10,39])])"
    assert_equal(a.notes.length,1)
    a = zparse "(: (1,(2,[4,5,(6,9),10])) :4)"
    assert_equal(a.notes.length,4)
    a = zparse "q (0 1 2 3)+(1,3)" # Adding random stuff to set
    assert_equal(a.notes.length,4)
    a = zparse "q (0 1 2 3)*(-1 1 -1 1)" # Cartesian product
    assert_equal(a.pcs,[0, 6, 5, 4, 0, 1, 2, 3, 0, 6, 5, 4, 0, 1, 2, 3])
    a = zparse "q (1 2 3 4)+[1 3, 2 2, 3 1]" # Cartesian sum with a random set
    assert_equal(a.pcs,[2, 3, 4, 5, 1, 2, 3, 4, 4, 5, 6, 0])
    a = zparse "(1 2 3)<>(4 5 3)" # Zip to sets
    assert_equal(a.pcs,[1, 4, 2, 5, 3, 3])

    # Random note
    a = zparse "q 0 ? 1 ? 2 ? 3 ?"
    assert_equal(a.pcs.length,8)
    # Random percents
    a = zparse "% ? % ?" # Can be used as random sleep
    assert_equal(a.pcs.length,2)
    a = zparse "{%>0.5?0:4} 3" # But mostly useful in conditional statements
    assert_equal(a.notes.length,2)

    ## Random integer between x and y
    a = zparse "(1,5)" # Random number between 1 and 5
    assert_equal(a.notes.length,1)
    a = zparse "(: (1,4) :4)" # Random number between 1 and 4 - 4 times
    assert_equal(a.notes.length,4)
    a = zparse "([2,4,6],[7,8,12])" # Generates random number between numbers picked from a spesific set of numbers
    assert_equal(a.notes.length,1)

    ## Random decimal

    a = zparse "(0.1,0.25) 1"
    assert_equal(a.durations.length,1)
    a = zparse "R<(0.1,2.0)> (0.1,1.0) 0..3"
    assert_equal(a.vals(:release).length,4)
    a = zparse "q ~<(0.1,1.0)>0123"
    assert_equal(a.vals(:slide).length,1)

    # Lists
    a = zparse "(0 1 2 3)+3" # Add 3 to each in a set
    assert_equal(a.pcs,[3,4,5,6])
    a = zparse "(0 1 2 3)+(1,6)" # Add a random number to each in a set
    assert_equal(a.notes.length,4)
    a = zparse "(0 1 2 3)<<(0,3)" # Add a random number to each in a set
    assert_equal(a.notes.length,4)
    a = zparse "(0 1 2 3)<<(1,3)" # Do a binary left switch using random number
    assert_equal(a.notes.length,4)
    a = zparse "(1 2 3)+(2 4 6)" # Do cartesian sum with two sets
    assert_equal(a.pcs,[3, 4, 5, 5, 6, 0, 0, 1, 2])
    a = zparse "((1 2 3)*(2 4 6))%7" # Do cartesian product with two sets and use mod 7
    assert_equal(a.pcs,[2, 4, 6, 4, 1, 5, 6, 5, 4])

    a = zparse "(1 2 3)<>(3 6 3)" # Zip to sets
    assert_equal(a.pcs,[1, 3, 2, 6, 3, 3])
    a = zparse "(1 2 3)<+>(3 6 3)" # Product of two sets
    assert_equal(a.pcs,[1, 3, 1, 6, 1, 3, 2, 3, 2, 6, 2, 3, 3, 3, 3, 6, 3, 3])
    a = zparse "(1 2 3)<*>(3 6 3)" # Two sets interval multiplication
    assert_equal(a.pcs,[3, 6, 3, 4, 0, 4, 5, 1, 5])
    a = zparse "(1 2 3)<&>(3 6 3)" # Intersection of two sets
    assert_equal(a.pcs,[3])
    a = zparse "(1 2 3)<|>(3 6 3)" # Union of two sets
    assert_equal(a.pcs,[1, 2, 3, 6])
    a = zparse "(1 2 3)<->(3 6 3)" # Difference of two sets
    assert_equal(a.pcs,[1,2])
    a = zparse "(0 1 1 2)!" # ! Unique set: 0 1 2
    assert_equal(a.pcs,[0,1,2])

    a = zparse "(1 2 3 4).r" # Reflect set. Nice for loops
    assert_equal(a.pcs,[1, 2, 3, 4, 3, 2])
    a = zparse "q ((-3..4){(3x+2)(3x^3)})$" # $ Splits generated integers 1432 -> 1 4 3 2
    assert_equal(a.pcs,[1, 4, 2, 1, 2, 6, 0, 4, 0, 1, 1, 0, 2, 1, 0])
    a = zparse "q ((-3..4){(3x+2)(3x^3)})&" # $ Splits generated integers 1432 -> 1 4 3 2
    assert_equal(a.pcs,[[1, 4], [2, 1], 2, 6, 0, [4, 0], [1, 1, 0], [2, 1, 0]])
    a = zparse "q ((-3..4){(3x+2)(3x^3)})$!" # Unique set and reflect can be combined
    assert_equal(a.pcs,[1, 4, 2, 6, 0, 1])

    a = zparse "((1000,5000))&" # Generates a chord: 1243
    assert_equal(a.pcs.length,1)
    a = zparse "(1,30) ((1,30))$ ((1,30))&" # Generates: {23} 2 3 14"
    assert_equal(a.pcs.length,4)
    a = zparse "(((10,50),(100,1000)))&" # Generates random chord between random numbers
    assert_equal(a.pcs.length,1)
    a = zparse "(((10,50),(100,1000)))$" # Generates random list from random numbers
    assert_equal(a.pcs.length,3)
    a = zparse "10..12" # Sequence: =10 =11 =12
    assert_equal(a.pcs,[3,4,5])
    a = zparse "(10..12)&" # Sequence: 10 11 12
    assert_equal(a.pcs,[[1, 0], [1, 1], [1, 2]])
    a = zparse "(10..12)$" # Sequence: 1 0 1 1 1 2
    assert_equal(a.pcs,[1, 0, 1, 1, 1, 2])
    a = zparse "q (100..200+8)&" # Sequence of chords: 100 108 116 124 132 140 148 156 164 172 180 188 196
    assert_equal(a.pcs.length,13)
    a = zparse "1..7" # Sequence: 1 2 3 4 5 6 7
    assert_equal(a.pcs.length,7)

    a = zparse "q 0..(1,7)" # Random sequence from 0 to random
    assert_equal(a.pcs[0],0)
    a = zparse "0..6+2" # Sequence: 0 2 4 6
    assert_equal(a.pcs,[0, 2, 4, 6])
    a = zparse "0..6+4" # Sequence: 0 4
    assert_equal(a.pcs,[0,4])
    a = zparse "0..6*4" # Sequence: 0 4 8 12 16 20
    assert_equal(a.pcs,[0, 4, 1, 5, 2, 6])
    a = zparse "0..4**2" # Geometric sequence: 1 2 4 8
    assert_equal(a.pcs,[1, 2, 4, 1])
    a = zparse "-3..4*3" # Sequence: -3 0 3 6
    assert_equal(a.pcs,[4, 0, 3, 6])
    a = zparse "a (0..3*(1,7)) h ((0,2)..2*(1,9)) a (0..3*(-7,-5))"
    assert_equal(a.pcs.length,8)
    a = zparse "q (0..4*3)+(2..-5*2)"
    assert_equal(a.pcs,[2, 5, 1, 4, 0, 3, 6, 2, 5, 1, 4, 0, 3, 6, 2, 5, 1, 4, 0, 3])
    a = zparse "(1..7)~" # Sequence in random order: "2135764"
    assert_equal(a.pcs.length,7)
    a = zparse "(1..7)~3" # Sequence from 1 to 7 take random 3: "152"
    assert_equal(a.pcs.length,3)
    a = zparse "(1..9+2)?3" # Can be combined with take random
    assert_equal(a.pcs.length,3)
    a = zparse "(1 3 4 6 7)~2" # Take different random 2: "3 6"
    assert_equal(a.pcs.length,2)
    a = zparse "(1 3 4 6 7)?2" # Take random 2: "3 3"
    assert_equal(a.pcs.length,2)
    a = zparse "<q e e q>(: (1,4)..[5,6,7] :3)~" # Create random range between randomized values and add note lengths

    # Assign
    a = zparse "A=(1..3 {(1,3)+2}) q A A A"
    assert_equal(a.pcs,[1, 2, 3, 5, 1, 2, 3, 5, 1, 2, 3, 5])
    a = zparse "A=(3 2 (1,5) 3) B=(? (1,3) 3) q A B A B"
    assert_equal(a.pcs,[3, 2, 4, 3, 5, 3, 3, 3, 2, 4, 3, 5, 3, 3])

  end
end

def test_effects

  # Fade
  a = zparse "q 0 1 2 3 4 5 6 7", fade: 1..0
  a = zparse "q 0 1 2 3 4 5 6 7", fade: 0.5..2
  a = zparse "q 0 2 1 3 5 4 6", fade_in: 2 # Loop fading in 2 rounds
  a = zparse "q 6 4 3 2 1 0 -1", fade_out: 2, fade: 2.0..0.25 # Loop fading out in 2 rounds. Starting from 2.0 to 0.25

  a = zparse "q 0 2 1 3 5 4 6", fade: 0..1, fade_in: 3, fader: :expo # Loop fading in 2 rounds

  # Adjusting Parameters
  a = zparse "q 1 1 2 3 4 5 6 7", pan: tweak(:quint,-1,1,7).mirror
  assert_equal(a.vals(:pan),[-0.9980960314154816, -0.9390730052954126, -0.5373356339620398, 0.5373356339620394, 0.9390730052954126, 0.9980960314154816, 1.0, 1.0])
  a = zparse "q 2 1 2 3 4 5 6 7", release: tweak(:quint,0.1,0.5,7).mirror, synth: :piano
  assert_equal(a.vals(:release),[0.10038079371690367, 0.11218539894091747, 0.19253287320759205, 0.40746712679240793, 0.4878146010590826, 0.4996192062830963, 0.5, 0.5])
  a = zparse "q 3 1 2 3 4 5 6 7", pan: tweak(:cubic,-1,1,10)
  assert_equal(a.vals(:pan),[-0.992, -0.9359999999999999, -0.784, -0.4879999999999999, 0.0, 0.488, 0.7839999999999998, 0.9359999999999999])
  a = zparse "q 4 1 2 3 4 5 6 7", amp: tweak(:expo,0,2,10).mirror
  assert_equal(a.vals(:amp),[0.00390625, 0.015625, 0.0625, 0.25000000000000006, 1.0, 1.75, 1.9375, 1.984375])

  ## Adjusting with lambdas

  a = zparse "q 5 1 3 2 4 5 6 7 8 9", release: ->(){rrand_i(0,1)}
  a = zparse "q 6 1 3 2 4 5 6 7 8 9", pan: ->(i){i%2==0 ? 0 : 1}
  a = zparse "q 7 1 3 2 4 5 6 7 8 9", retrograde: ->(i){ i%3==0}

  # tweak
  quad = (tweak :quad,-1,1,10).ring.mirror
  expo = (tweak :expo,0,10,30).ring.mirror
  sine = (tweak :cubic,0,30,100).ring.mirror
  quint = (tweak :quint,0,20,40).ring.mirror

  ## Adjusting samples
  m = {
    K: { sample: :drum_heavy_kick, amp: tweak(:linear,0,1,20), pan: [0,1,-1].ring},
    S: { sample: :drum_snare_soft, amp: [0.25,0.5,1.0,1.5,1.0,0.5].ring },
    H: { sample: :drum_cymbal_closed, amp: tweak(:sine,0,1,20), pan: tweak(:sine,-1,1,20).ring.mirror },
    O: { sample: :drum_cymbal_open, amp: ->(){rrand 0.5, 2.0}}
  }

  a = zparse "[: h [KH H] [SH H] [KH KH] <[SH H];[SH K]> :]", use: m

  # Running with effects
  a = zparse "|h 1 2 3 4 | 4 3 2 1|", run: [
    {with_bpm: 120},
    {with_fx: :echo},
    {with_fx: :bitcrusher, bits: 5 }
  ]

  a = zparse "B K (B B) K",
    run: [{with_bpm: 120}],
  use: {
    B: :bd_fat,
    K: { sample: :drum_snare_soft, run: [{with_fx: :echo}] }
  }

  a = zparse "B K (B B) K",
    run: [{with_bpm: 120}],
  use: {
    B: :bd_fat,
    K: { sample: :drum_snare_soft },
    run: [{with_fx: :echo}]
  }

  ## Adjusting Effects

  a = zparse "q 1 3 2 4", run: [
    {with_fx: :ixi_techno, phase: tweak(:sine, 0.01,1.0,10).ring.mirror}
  ]

  a = zparse "e 0 1 2 3 4 5 6 7 8 7 6 5 4 3 2 1 0", run_each: [
    {with_fx: :flanger, phase: tweak(:sine, 0.05,1.0,10).ring.mirror}
  ]

  m = {
    K: { sample: :drum_heavy_kick, pan: [0,1,-1].ring},
    S: { sample: :drum_snare_soft, amp: [0.25,0.5,1.0,1.5,1.0,0.5].ring,
         run: [{with_fx: :wobble, phase: tweak(:quint,0.1,5.0,10).ring.mirror}] },
    H: { sample: :drum_cymbal_closed, pan: tweak(:sine,-1,1,20).ring.mirror,
         run: [{with_fx: :ixi_techno, phase: ->(){rrand 0.01,0.1}}] },
    O: { sample: :drum_cymbal_open, amp: ->(){rrand 0.5, 2.0}}
  }

  a = zparse "h (KH H) (SH H)", use: m
  a = zparse "P1 q1234", detune: 10
  a = zparse "P-1 q1234"

end

def test_rules
  # Rules

  a = zparse "q 1", rules: {"1"=>"1 3","3"=>"6 (2,7) 3 1"}, gen: 3

  a = zparse "@(q 0 4 123) i iv",
  rules: {
    " i "=>" i^m7 iv ",
    " iv "=>" vii iii i ",
    " vii "=>" iv ii "
  }, gen: 6, scale: :blues_major, stable: true

  a = zparse "(1,7)",
  rules: {
    "1"=>"(1,7)",
    "8"=>"(1,7)"
  }, gen: 6, stable: true

  a = zparse "1", rules: {/(3)1/=>"q ={$1+1} 1 ={$1+2}",/[1-7]/=>"e313"}, gen: 4, parse_chords: false

  a = zparse "1 2 3", rules: {/[1-9]/=>"={$*1} [e,q] ={$*2}"}, gen: 4, parse_chords: false

  a = zparse "q 0 1 e 2 3 q 1", rules: {"0"=>"1", "1"=>"3", "3"=>"(1,6)", /[0-9]/=>"3" }

  a = zparse "q0", synth: :dull_bell, scale: :gong, rules: {
    /e([0-6]) e([0-6])/ => "q={$1+2} q={$2+1}",
    /q([0-5]) q([0-5]) q([0-5])/ => "q(0,5)",
    /q[0-5]/ => "e0 e(2,4)"
  }

  a = zparse "q 1 2 3 4", rules: {"1"=>"{%>0.2?(1..9):6}"}, gen: 9
  a = zparse "q 1 2 3 4", rules: {/[1-7]/=>"{%>0.3?(0,3):(4,7)}"}, gen: 3
  a = zparse "q 1 2 3 4", rules: {"1"=>->(){rand<0.2 ? "2 1 3" : "1"}}, gen: 9

  a = zparse "q 1 2 3 4", rules: {"3"=>["7 3",nil,"9 4"]}, gen: 12

  a = zparse "q 1 2 3 4", rules: {"3"=>(ring nil, nil,"1 4 2 3")}, gen: 12

  a = zparse "0 1 2", rules: { /([0-9])/=> ->(i,g){ print g ; g[0] } }

  a = zparse "9 8 7 6 5 4", rules: {/([0-9]) ([0-9])/=>->(i,g){ g[1].to_i+g[2].to_i}, /[0-9]/=>"$ 1 2"  }

  a = zparse "q 0 1 e 2 3 q 1", rules: {"0"=>"1", "1"=>"3", "3"=>->(){rrand_i(1,5)}, /[0-9]/=>"3" }

  melody = "[:q 0 1 2 0:][:q 2 3 h4:]"
  a = zparse melody, synth: :dsaw, replace: {"1"=>"r","4"=>"r"}
  a = zparse melody, synth: :chiplead, replace: {"0"=>"r","2"=>"r","4"=>"r"}

  a = zparse "q 1", seed: 1, rules: {
    "1"=>"2",
    "2"=>"3",
    "3"=>"[1,2]"
  }

  a = zparse "q 0 1 e 2 3 4 5", reset: true, seed: 3, rules: {
    "0"=>"[1,3]",
    "1"=>"[0,4]",
    "2"=>"4",
    "3"=>"2",
    "4"=>"[0,2]"
  }

end

def test_transformations

  a = zparse "q 0 2 1 4"
  assert_equal(a.pcs,[0,2,1,4])
  b = a.inverse
  assert_equal(b.pcs,[0, 5, 6, 3])
  c = a.retrograde
  assert_equal(c.pcs,[4,1,2,0])
  d = a.inverse.retrograde
  assert_equal(d.pcs,[3, 6, 5, 0])
  e = a.transpose -3
  assert_equal(e.pcs,[4, 6, 5, 1])
  f = a.retrograde 0,2
  assert_equal(f.pcs,[4, 1, 2, 0])
  g = a.rotate 2
  assert_equal(g.pcs,[1, 4, 0, 2])
  h = a.swap 3
  assert_equal(h.pcs,[4, 2, 1, 0])
  i = a.swap 1,3
  assert_equal(i.pcs,[2, 0, 1, 4])
  k = a.reflect
  assert_equal(k.pcs,[0, 2, 1, 4, 1, 2])
  l = a.mirror
  assert_equal(l.pcs,[0, 2, 1, 4, 1, 2, 0])
  m = a.fuse zparse("1 2 3")
  assert_equal(m.pcs,[1, 5, 2, 6, 3, 7, 4, 8, 1, 5, 2, 6, 3, 7, 4, 8, 2, 6, 3, 7, 4, 8, 5, 9, 2, 6, 3, 7, 4, 8, 5, 9, 3, 7, 4, 8, 5, 9, 6, 10, 3, 7, 4, 8, 5, 9, 6, 10])

  ## Transpose

  a = zparse("q 0 3 6 8").transpose(-3)
  assert_equal(a.pcs,[4, 0, 3, 5])

  ## Add

  a = zparse("q 0 3 6 8").plus(-3)
  assert_equal(a.pcs,[4, 0, 3, 5])

  ## Multiply

  a = zparse("q 0 3 6 8").multiply(2)
  assert_equal(a.pcs,[0, 6, 5, 2])

end

test_generative
test_effects
test_rules
test_transformations

print "All tests OK"
