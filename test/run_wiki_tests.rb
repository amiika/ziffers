load "~/ziffers/ziffers.rb"

Ziffers.debug

def test_melody

  # Note lengths
  a = zparse "|q 4 2 4 2 |q 4 5 4 2 |q 3 1 3 1 |q 3 4 3 1 |q 4 2 4 2 |q 4 5 4 2 | w4 |q 4 3 2 1 | w0 |"
  assert_equal(a.pcs,[4, 2, 4, 2, 4, 5, 4, 2, 3, 1, 3, 1, 3, 4, 3, 1, 4, 2, 4, 2, 4, 5, 4, 2, 4, 4, 3, 2, 1, 0])

  # Decimal notation
  a = zparse "0.25 4 2 4 2 4 5 4 2 3 1 3 1 3 4 3 1 4 2 4 2 4 5 4 2 1.0 4 0.25 4 3 2 1 30.0 0 8"
  assert_equal(a.durations,[0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 1.0, 0.25, 0.25, 0.25, 0.25, 30.0, 30.0])

  # Ties
  a = zparse "q 0 qe 2 3 4 qee 3 4"
  assert_equal(a.durations,[0.25, 0.375, 0.375, 0.375, 0.5, 0.5])

  # Subdivision
  a = zparse "w [4 2 4 2] [4 5 4 2] [3 1 3 1] [3 4 3 1] [4 2 4 2] [4 5 4 2] 4 [4 3 2 1] 0"
  assert_equal(a.durations,[0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 1.0, 0.25, 0.25, 0.25, 0.25, 1.0])
  a = zparse "w [1 2 3 4] h [1 2 3 4] q [1 2 3 4] w [1 2[3 4]] h [ 1 [ 2 [ 3 [ 4 ]]]]"
  assert_equal(a.durations,[0.25, 0.25, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125, 0.0625, 0.0625, 0.0625, 0.0625, 0.3333333333333333, 0.3333333333333333, 0.16666666666666666, 0.16666666666666666, 0.25, 0.125, 0.0625, 0.0625])

  # Triplets
  a = zparse "q 2 6 a 1 3 2 q 5 1 a 4 3 2"
  assert_equal(a.durations,[0.25, 0.25, 0.167, 0.167, 0.167, 0.25, 0.25, 0.167, 0.167, 0.167])
  a = zparse "q 2 6 h [1 3 2] q 5 1 h [4 3 2]"
  assert_equal(a.durations.map{|v| v.round(3)},[0.25, 0.25, 0.167, 0.167, 0.167, 0.25, 0.25, 0.167, 0.167, 0.167])

  # Parameters
  a = zparse "1 2 3", release:0.25, duration: 0.25
  assert_equal(a.durations,[0.25,0.25,0.25])

  a = zparse "1 2 3", release: [0.25,0.5].ring, duration: [0.25,0.5].ring
  assert_equal(a.durations,[0.25,0.5,0.25])
  assert_equal(a.beats,[1.0,2.0,1.0])
  assert_equal(a.vals(:release),[0.25,0.5,0.25])

  # Rests
  a = zparse "q 1 h r 2", key: :d
  assert_equal(a.pcs,[1,nil,2])

  # Microtonality
  a = zparse "q 0 3 2 5 3 6", key: 59.34, scale: [0.3,0.12,1.234,2.2], synth: :kalimba
  assert_equal(a.pcs,[0,3,2,1,3,2])
  a = zparse "q (: {(0.1,2.9)} {(3.1,6.9)} :4)", key: :D, scale: :minor, synth: :kalimba # Microtonal melody within given key and scale
  assert_equal(a.notes,[65.6005126953125, 71.77777099609375, 64.7995361328125, 69.10736083984375, 62.4030029296875, 70.9142822265625, 66.20574951171875, 71.09866943359376])
  a = zparse "q {1.1 2.3 3.4}" # Multiple escaped microtonal pitches
  assert_equal(a.notes,[62.2, 64.9, 66.6])

  # Octave change
  a = zparse "q 0 1 2 ^ 0 ^^ 1 2 _ 0 1 2 __ 0 1 2" # Octaves changed for following notes
  assert_equal(a.octaves,[0, 0, 0, 1, 3, 3, 2, 2, 2, 0, 0, 0])
  a = zparse "q 0 _4 0 ^1 _1^3__2" # Change octave for single notes only
  assert_equal(a.octaves,[0, -1, 0, 1, [-1,1,-2]])
  a = zparse "q 0 <-1> 0 2 <0> 0 1" # Change octave explicitly to certain value for all following notes
  assert_equal(a.octaves,[0, -1, -1, 0, 0])
  a = zparse "_A A ^A", A: :ambi_choir # Change pitch of the sample
  assert_equal(a.pitches, [-12.0, nil, 12.0])
  a = zparse "q 1 2 ^ 3 4 ^ 0 ^ 4 3 ___ 2 1", octave: -1 # Staff octave is set to -1
  assert_equal(a.octaves,[-1, -1, 0, 0, 1, 2, 2, -1, -1])
  a = zparse "1 1__3^3 1<3>3<1>3" # Both syntaxes can be used with chords
  assert_equal(a.octaves,[0, [0, -2, 1], [0, 3, 1]])
  a = zparse "|q _ 0 1 | 0 1 |" # Octaves (and durations) are reseted in each measure
  assert_equal(a.octaves,[-1, -1, 0, 0])

  # Negative degrees
  a = zparse "-9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9"
  assert_equal(a.pcs,[5, 6, 7, 1, 2, 3, 4, 5, 6, 0, 1, 2, 3, 4, 5, 6, 0, 1, 2])

  # Escape degrees
  a = zparse "{-10} {12} {24}"
  assert_equal(a.pcs, [4, 5, 3])
  a2 = zparse "{-10 12 24}"
  assert_equal(a.pcs,a2.pcs)
  a = zparse "{1*1} {2*2} {3*3} {4*4}"
  assert_equal(a.pcs,[1, 4, 2, 2])

  a = zparse 1
  assert_equal(a.pcs,[1])

  a = zparse [0,1,2]
  assert_equal(a.pcs,[0,1,2])

  # Measures

  a = zparse "| q _ 0 1 | 2 3 | 5 6 | 7 8 |"
  assert_equal(a.measures.length,4)
  assert_equal(a.measures[2].pcs,[5,6])
  assert_equal(a.hash_measures.keys,[1,2,3,4])
  assert_equal(a.group_measures(2).length,2)

  measures = a.measures
  ar = measures[0].retrograde
  assert_equal(ar.pcs,[1,0])
  at = measures[1].transpose(1)
  assert_equal(at.pcs,[3,4])
  ar2 = measures[2].retrograde(2)
  assert_equal(ar2.pcs,[6,5])
  ai = measures[3].inverse(2)
  assert_equal(ai.pcs,[2,1])

  # Repeats

  a = zparse "[: q 0 1 2 0 :] [: q 2 3 h4 :] [: [: e 4 5 4 3 q 2 0 :][: q 0 _4 h0 :] :]", key: :e, scale: :major
  assert_equal(a.pcs,[0, 1, 2, 0, 0, 1, 2, 0, 2, 3, 4, 2, 3, 4, 4, 5, 4, 3, 2, 0, 4, 5, 4, 3, 2, 0, 0, 4, 0, 0, 4, 0, 4, 5, 4, 3, 2, 0, 4, 5, 4, 3, 2, 0, 0, 4, 0, 0, 4, 0])
  assert_equal(a.durations,[0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5])

  a = zparse "[: q 0 e0 e0 0 1 | q 2 0 0 2 | < (q 1 -1 -1 1 | q 2 0 h0) (q.4 e3 q 2 1  | q 2 0 h0)> :] "\
    "[: q 4 e4 e4 3 2 | q 1 -1 -1 1 | <(q 3 e3 e3 2 1 | q 2 0 0 2) (q 3 e3 e3 2 1 | q 2 0 h0)> :]", key: :g, scale: :minor
  assert_equal(a.measures.length,16)

  a = zparse "[: 1 <2 3 4 5 6 7> :7]"
  assert_equal(a.pcs,[1,2,1,3,1,4,1,5,1,6,1,0,1,2])

  a = zparse "[: 1 <2 3 4 5 6 7> :7]"
  assert_equal(a.pcs,[1,2,1,3,1,4,1,5,1,6,1,0,1,2])

  a = zparse "[: 0 2 <1 3 <4 7>> :6]" # Cycles with normal repeat
  b = zparse "(: 0 2 <1 3 <4 7>> :6)" # Cycles with generative repeat
  assert_equal(a.pcs,b.pcs)

  a = zparse "(: 3 <3 6> 7 <2 1> 4 <3 <5 (e 4 3)>> :4)"
  assert_equal(a.pcs,[3, 3, 0, 2, 4, 3, 3, 6, 0, 1, 4, 5, 3, 3, 0, 2, 4, 3, 3, 6, 0, 1, 4, 4, 3])

  # Control characters

  a = zparse "q P1 0 1 2 P-1 0 3 4"
  assert_equal(a.vals(:pan),[1, 1, 1, -1, -1, -1])
  a = zparse "q A<0.1> 0 1 2 A<2.0> 0 1 2"
  assert_equal(a.vals(:amp),[0.1, 0.1, 0.1, 2.0, 2.0, 2.0])
  a = zparse "q B<0.1> 0 1 2 B<2.0> 0 1 2"
  assert_equal(a.vals(:attack),[0.1, 0.1, 0.1, 2.0, 2.0, 2.0])
  a = zparse "q 0 3 5 <minor> 0 3 5 "
  assert_equal(a.vals(:scale),[:major, :major, :major, :minor, :minor, :minor])
  a = zparse "q 0 3 5 K<g3> 0 3 5 "
  assert_equal(a.vals(:key),[:c, :c, :c, "g3", "g3", "g3"])
  a = zparse "q X0 123 5 3 2 X<0.5> 123 5 3 2"
  assert_equal(a.vals(:chord_duration),[0, 0, 0, 0, 0.5, 0.5, 0.5, 0.5])

  # Accents or Dynamics

  # Tired of fixing these ... for some reason Sonic Pi opens these in different encoding
  #a = zparse "0 `1 ´2 ``1 ´´2"
  #assert_equal(a.vals(:amp),[nil, 0.5, 1.5, 0.3333333333333333, 2.0])
  a = zparse "X `H", X: :bd_boom, H: :drum_cymbal_closed, amp: 2.0 # Same as A<3.0>
  assert_equal(a.vals(:amp),[2.0, 1.0])

  # Staccato

  a = zparse "h 0 '0 ''0 '''0"
  assert_equal(a.vals(:release),[2.0, 1.3333333333333333, 1.0, 0.8])
  a = zparse "A 'A ''A '''A", A: :ambi_choir
  assert_equal(a.vals(:pitch_stretch),[nil, 0.6666666666666666, 0.5, 0.4])


  # Slide

  a = zparse "q ~09"
  assert_equal(a.vals(:slide)[0].pcs,[0,2])
  a = zparse "q ~0123"
  assert_equal(a.vals(:slide)[0].pcs,[0,1,2,3])
  a = zparse "q ~<0.1>01910 "
  assert_equal(a.vals(:slide)[0].pcs,[0,1,2,1,0])


  # Alternative degree based notation

  Ziffers.set_degree_based true

  a = zparse "1 3 5 4 6 8"
  assert_equal(a.pcs,[0, 2, 4, 3, 5, 0])
  a = zparse "0 7" # Note that 0 means rest in degree based notation
  assert_equal(a.pcs,[nil, 6])

  Ziffers.set_degree_based false

end

def test_play

  # zparse

  a = zparse "q 0 2 1 4"
  b = a.inverse
  c = a.retrograde
  d = a.inverse.retrograde
  e = a.transpose -3
  assert_equal(a.pcs,[0, 2, 1, 4])
  assert_equal(b.pcs,[0, 5, 6, 3])
  assert_equal(c.pcs,[4, 1, 2, 0])
  assert_equal(d.pcs,[3, 6, 5, 0])
  assert_equal(e.pcs,[4, 6, 5, 1])

  # zplay

  a = zparse 1 # Plays in :c :major
  assert_equal(a.pcs,[1])
  a = zparse [1,2,3], key: "f", duration: 0.25
  assert_equal(a.pcs,[1,2,3])
  a = zparse "w1 h2 q3"
  assert_equal(a.pcs,[1,2,3])
  a = zparse [[1,1],[2,0.5],[3,0.25]] # Is same as w1 h2 q3
  assert_equal(a.durations,[1.0,0.5,0.25])

  # Synths

  use_synth :blade
  a = zparse "q 0 1 2 3"
  assert_equal(a.vals(:synth),[nil, nil, nil, nil])
  a = zparse "q 0 1 2 3", synth: :chipbass
  assert_equal(a.vals(:synth),[:chipbass, :chipbass, :chipbass, :chipbass])

  # Midi

  a = zparse "(123..126)~", scale: :hex_sus, port: "loopmidi", channel: 3
  assert_equal(a.orig_pcs,[125, 123, 126, 124])
  assert_equal(a.vals(:port),["loopmidi", "loopmidi", "loopmidi", "loopmidi"])
  assert_equal(a.vals(:channel),[3, 3, 3, 3])

  # Parse midi notes

  a = zparse "[: q 53 53 53 57 h 60 q 53 53 <(h 55 q 60 60 h 57 q 53 53) (q 55 55 57 55 w 53)> :]", midi: true, synth: :piano
  assert_equal(a.notes,[53, 53, 53, 57, 60, 53, 53, 55, 60, 60, 57, 53, 53, 53, 53, 53, 57, 60, 53, 53, 55, 55, 57, 55, 53])

  # Parse degrees from notes

  a1 = zparse "[: 0.25 c d e c:][: 0.25 e f 0.5 g:] [: [:0.125 g a g f 0.25 e c:] [: 0.25 c _g 0.5 c:] :]", parsekey: :c, key: :e
  a2 = zparse "w [: [c d e c] :] [: [[e f] g] :] [: [: [[g a][g f] e c] :][: [[c _g] c] :] :]", parsekey: :c, key: :g
  assert_equal(a1.durations,a2.durations)

  # Sample synth

  a = zparse "[: q 4 4 3 e 4 5 | q 0 1 2 1 2 2 4 5 | q 2 2 3 | e 4 5 6 4 5 3 4 2 3 2 :]", sample: :guit_e_fifths, start: 0.2, finish: 0.25, amp: 3
  assert_equal(a.pcs,[4, 4, 3, 4, 5, 0, 1, 2, 1, 2, 2, 4, 5, 2, 2, 3, 4, 5, 6, 4, 5, 3, 4, 2, 3, 2, 4, 4, 3, 4, 5, 0, 1, 2, 1, 2, 2, 4, 5, 2, 2, 3, 4, 5, 6, 4, 5, 3, 4, 2, 3, 2])

  # Rhythmic patterns with samples

  a = zparse "[ D [D D]] hD D", use: { D: :bass_woodsy_c }
  assert_equal(a.vals(:char),["D", "D", "D", "D", "D"])
  a1 = zparse "[: q X O e X X q O :2]", X: :bd_tek, O: :drum_snare_soft # Assign X and O for samples
  assert_equal(a1.vals(:char),["X", "O", "X", "X", "O", "X", "O", "X", "X", "O"])
  assert_equal(a1.samples,[:bd_tek, :drum_snare_soft, :bd_tek, :bd_tek, :drum_snare_soft, :bd_tek, :drum_snare_soft, :bd_tek, :bd_tek, :drum_snare_soft])
  a2 = zparse "[: q X O e X X q O :2]", use: {"X": :bd_tek, "O": :drum_snare_soft}
  assert_equal(a2.vals(:char),["X", "O", "X", "X", "O", "X", "O", "X", "X", "O"])
  assert_equal(a2.samples,[:bd_tek, :drum_snare_soft, :bd_tek, :bd_tek, :drum_snare_soft, :bd_tek, :drum_snare_soft, :bd_tek, :bd_tek, :drum_snare_soft])
  assert_equal(a1.samples,a2.samples)
  a = zparse "[: O q X X X X :2]", X: :bd_tek, O: {sample: :ambi_choir, rate: 0.3, duration: 0}
  assert_equal(a.vals(:rate),[0.3, nil, nil, nil, nil, 0.3, nil, nil, nil, nil])

  n = {
    B: :bd_tek,
    K: :drum_snare_soft,
    H: {sample: :drum_cymbal_closed, amp: 0.2}
  }

  a = zparse "[B H] [B [H H]] [BK H] [[BK B] H]", use: n
  assert_equal(a.vals(:char),["B", "H", "B", "H", "H", ["B", "K"], "H", ["B", "K"], "B", "H"])
  a = zparse "[B H] [B [H H]] [BK H] [[BK B] H]", B: 60, H: 70, K: 90, midi: true, port: "loopmidi"
  assert_equal(a.notes,[60, 70, 60, 70, 70, [60, 90], 70, [60, 90], 60, 70])

  breakbeat = "| HB H | HS [H B] | [H B] [H B] | HS [H B] |
             | HB H | HS H     | [H H] [r B] | HS [H H] |"

  samples = {
    B: :bd_tek,
    S: :drum_snare_soft,
    H: {sample: :drum_cymbal_closed, amp: 0.2}
  }

  a = zparse breakbeat, use: samples
  assert_equal(a.samples,[[:drum_cymbal_closed, :bd_tek], :drum_cymbal_closed, [:drum_cymbal_closed, :drum_snare_soft], :drum_cymbal_closed, :bd_tek, :drum_cymbal_closed, :bd_tek, :drum_cymbal_closed, :bd_tek, [:drum_cymbal_closed, :drum_snare_soft], :drum_cymbal_closed, :bd_tek, [:drum_cymbal_closed, :bd_tek], :drum_cymbal_closed, [:drum_cymbal_closed, :drum_snare_soft], :drum_cymbal_closed, :drum_cymbal_closed, :drum_cymbal_closed, nil, :bd_tek, [:drum_cymbal_closed, :drum_snare_soft], :drum_cymbal_closed, :drum_cymbal_closed])

  # Comments

  a = zparse "| 2 3 |q <! This is a comment > 2 | e 4 2 |"
  assert_equal(a.pcs,[2,3,2,4,2])
  a = zparse "|q 2 3 <! | q 1 2 > |  e 4 2 |"
  assert_equal(a.pcs,[2,3,4,2])

end

def test_rhythm

  ## Rhythmic motive

  a1 = zparse "0 1 2 3", rhythm: [0.25,0.25,0.5]
  a2 = zparse "0 1 2 3", rhythm: (ring 0.25,0.25,0.5)
  assert_equal(a1.durations,a2.durations)
  a = zparse "0 1 2 3", rhythm: spread(4,4)
  assert_equal(a.durations,[0.25,0.25,0.25,0.25])
  a = zparse "0 1 2 3", rhythm: spread(1,4)
  assert_equal(a.durations,[1.0,1.0,1.0,1.0])
  a = zparse "0 1 2 3", rhythm: "eeq"
  assert_equal(a.durations,[0.125,0.125,0.25,0.125])
  a = zparse "1 2 3", rhythm: {0=>0.35,1=>"q",2=>"h",3=>"q",4=>"e",5=>"e",6=>"q",7=>"q",8=>"e"}
  assert_equal(a.durations,[0.25, 0.5, 0.25])
  a = zparse "1 2 3", rhythm: {binary: 0x0F }
  assert_equal(a.durations,[0.25, 0.25, 0.25])
  a = zparse"0 1 2 3 4 5", rhythm: {binary: 0x1234 }
  assert_equal(a.durations,[0.23076923076923078, 0.3076923076923077, 0.07692307692307693, 0.15384615384615385, 0.23076923076923078, 0.23076923076923078])

  # TODO: Tests for schillinger

  ## Euclidean rhythm

  a = zparse "q (X)<2,4>", X: :bd_haus
  assert_equal(a.vals(:char),["X",nil,"X",nil])
  a = zparse "q (X S)<2,4>", X: :bd_haus, S: :drum_snare_soft
  assert_equal(a.vals(:char),["X", nil, "S", nil])
  a = zparse "q (X S)<3,6,1>", X: :bd_haus, S: :drum_snare_soft
  assert_equal(a.vals(:char),[nil, "X", nil, "S", nil, "X"])
  a = zparse "q (X S)<5,8>(H Z)", X: :bd_haus, S: :drum_snare_soft, H: :drum_cymbal_closed, Z: :drum_cymbal_open
  assert_equal(a.vals(:char),["X", "H", "S", "Z", "X", "S", "H", "X"])
  a = zparse "((e 1 3) (e 5 2))<5,7>(q6 q5)"
  assert_equal(a.pcs,[1, 3, 6, 5, 2, 1, 3, 5, 5, 2, 1, 3])
  a = zparse "(0 1 2)<1,5>(3 4 5)"
  assert_equal(a.pcs,[0,3,4,5,3])
  a = zparse "(0 1 2)<2,5>(3 4 5)"
  assert_equal(a.pcs,[0,3,4,1,5])
  a = zparse "(0 1 2)<2,5>(<3 4> 5)"
  assert_equal(a.pcs,[0,3,5,1,4])
end

test_melody
test_play
test_rhythm

print "All tests OK"
