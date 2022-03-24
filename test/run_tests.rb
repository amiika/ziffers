load "~/ziffers/ziffers.rb"

#Ziffers.debug

def test1
  
  # Test different timing notations
  
  m1 = zparse("[: q. 0 0 | q0 e1 q.2 |q2 e1 q2 e3| h.4 | 0.125 7 7 7 4 4 4 2 2 2 0 0 0| q4 e3 q2 e1 | h.0 :]")
  print m1
  m1_s = m1.durations
  m1_n = m1.notes
  m1_n_assert = [0.375, 0.375, 0.25, 0.125, 0.375, 0.25, 0.125, 0.25, 0.125, 0.75, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.25, 0.125, 0.25, 0.125, 0.75, 0.375, 0.375, 0.25, 0.125, 0.375, 0.25, 0.125, 0.25, 0.125, 0.75, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.25, 0.125, 0.25, 0.125, 0.75]
  m1_s_assert = [60, 60, 60, 62, 64, 64, 62, 64, 65, 67, 72, 72, 72, 67, 67, 67, 64, 64, 64, 60, 60, 60, 67, 65, 64, 62, 60, 60, 60, 60, 62, 64, 64, 62, 64, 65, 67, 72, 72, 72, 67, 67, 67, 64, 64, 64, 60, 60, 60, 67, 65, 64, 62, 60]
  
  assert_equal(m1_s, m1_n_assert)
  assert_equal(m1_n, m1_s_assert)
  
end

def test2
  
  # Test loops and octaves etc.
  
  m2 = zparse("[:q _ 0 1 <-1> 2 <0>0:][: 2 3 h4:][:[:e 4 5 4 3 q 2 0:][:0 _4 h0:]:]", key: :e, scale: :major)
  print m2
  m2_s = m2.durations
  m2_n = m2.notes
  print m2_n
  assert_equal(m2_s,[0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5])
  assert_equal(m2_n, [52, 54, 56, 64, 52, 54, 56, 64, 56, 57, 59, 56, 57, 59, 59, 61, 59, 57, 56, 52, 59, 61, 59, 57, 56, 52, 52, 47, 52, 52, 47, 52, 59, 61, 59, 57, 56, 52, 59, 61, 59, 57, 56, 52, 52, 47, 52, 52, 47, 52])
end

def test3
  
  # Test list notation
  
  m3_1 = zparse "w 5 [[5 3][3 2 1 0]] 7 2"
  m3_2 = zparse "w 5 q 5 3 e 3 2 1 0 w 7 2"
  m3_1_s = m3_1.durations
  m3_2_s = m3_2.durations
  
  assert_equal(m3_1_s,m3_2_s)
  
  m4 = zparse "[[2 3] 0 [1 2 [2 3 [ 5 [2 3]]]]]"
  m4_s = zparams(m4,:sleep)
  assert_equal(m4_s,[0.16666666666666666, 0.16666666666666666, 0.3333333333333333, 0.1111111111111111, 0.1111111111111111, 0.037037037037037035, 0.037037037037037035, 0.018518518518518517, 0.009259259259259259, 0.009259259259259259])
  
  a = zparse "[:q 0 1 2 0:] [:q 2 3 h4:] [: [:e 4 5 4 3 q 2 0:] [:q 0 _4 h0:] :]"
  b = zparse "[: [0 1 2 0] :] [: [[2 3]4] :] [: [: [[4 5][4 3]2 0] :] [: [[0 _4] 0] :] :]"
  assert_equal(a.durations,b.durations)
  assert_equal(a.octaves,b.octaves)
end


def test4
  
  # Test some chords
  
  t4 = zparse "i", key: :d, scale: :major
  t4_n = t4[0].notes
  assert_equal(t4_n,(chord_degree :i, :d, :major, 3).to_a)
  
  t4_2 = zparse "i+1", key: :d, scale: :major
  t4_2_n = t4_2[0].notes
  assert_equal(t4_2_n,(chord_degree :i, :d, :major, 1).to_a)
  
  t4_3 = zparse "i^maj*2", key: :d, scale: :major
  t4_3_n = t4_3[0].notes
  assert_equal(t4_3_n,(chord :d, :major, num_octaves: 2).notes.to_a)
  
  t4_4 = zparse "_1^#1__b1"
  assert_equal(t4_4.notes.flatten,[50,75,37])
  
  t5 = zparse "i%1"
  t5_s = chord_invert (chord :c, :major), 1
  assert_equal(t5.notes[0],t5_s.to_a)
  
  t5 = zparse "i%-6"
  t5_s = chord_invert (chord :c, :major), -6
  assert_equal(t5.notes[0],t5_s.to_a)
  
end

def test5
  
  # Test negative degrees
  
  t5 = zparse "s E T 9 8 7 6 5 4 3 2 1 0 -1 -2 -3 -4 -5 -6 -7 -8 -9 -T -E"
  print t5
  t5n = zparams t5, :note
  print t5n
  assert_equal(t5n,[79, 77, 76, 74, 72, 71, 69, 67, 65, 64, 62, 60, 59, 57, 55, 53, 52, 50, 48, 47, 45, 43, 41])
end

def test6
  
  # Test lsystem
  
  # String replacement
  #t6_1 = lsystem "0", {"0"=>"1", "1"=>"2", "2"=>"0"}, 4, nil
  #assert_equal(t6_1,["1", "2", "0", "1"])
  
  # Regexp with '' eval syntax
  t6z_1 = zparse "q0 e0 1 2 3", rules: {/(?<=q)[0-9]/=>"{$+1}"}, gen: 3
  print t6z_1
  t6_2 = zparams(t6z_1, :pc)
  assert_equal(t6_2,[3, 0, 1, 2, 3])
  
  t6z_2 = zparse "q1 e3 q4", gen: 1, rules: {
    /([a-z])([1-9]*)/=> ->(i,m){ m[1]+(m[2].to_i+2).to_s }
  }
  t6_3 = zparams(t6z_2,:pc)
  assert_equal(t6_3, [3,5,6])
end

def test_chords
  tc = zparse "e i ii iii iv v vi vii"
  tc_res = [[60, 64, 67], [62, 65, 69], [64, 67, 71], [65, 69, 72], [67, 71, 74], [69, 72, 76], [71, 74, 77]]
  assert_equal(tc.notes,tc_res)
  tc = zparse "012 234 345 5679"
  tc_res =  [[60, 62, 64], [64, 65, 67], [65, 67, 69], [69, 71, 72, 76]]
  assert_equal(tc.notes,tc_res)
  a = zparse "e i ii iii iv v vi vii", chord_name: "minor", chord_sleep: 0.15, chord_synth: :piano
  assert_equal(a.notes,[[60, 63, 67], [62, 65, 69], [64, 67, 71], [65, 68, 72], [67, 70, 74], [69, 72, 76], [71, 74, 78]])
  a = zparse "T43 E34 931"
  assert_equal(a.orig_pcs,[[10, 4, 3], [11, 3, 4], [9, 3, 1]])
end

def test_octaves
  t_o = zparse "0 7 ^ 0 | 0 _ 0"
  t_o.octaves
  assert_equal(t_o.octaves,[0,1,1,0,-1])
  
  to2 = zparse "0 <1> 2 <-2> 2 <3>1"
  assert_equal(to2.octaves,[0, 1, -2, 3])
  
  a = zparse "_q1 0 2 3"
  assert_equal(a.octaves,[-1,0,0,0])
  
  a = zparse "<-2> 0 2 ^3"
  assert_equal(a.octaves,[-2,-2,-1])
  
end

def test_samples
  a = zparse "A q B e A A", A: :ambi_dark_woosh, B: :ambi_sauna
  assert_equal(a.samples, [:ambi_dark_woosh, :ambi_sauna, :ambi_dark_woosh, :ambi_dark_woosh])
  assert_equal(a.durations, [1.0, 0.25, 0.125, 0.125])
  
  a = zparse "q [: q HB H BHS H :2] q BH B q SH H ",
  use: {
    B: :bd_tek,
    S: :drum_snare_soft,
    H: {sample: :drum_cymbal_closed, amp: 0.2}
  }
  
  assert_equal(a.samples, [[:drum_cymbal_closed, :bd_tek], :drum_cymbal_closed, [:bd_tek, :drum_cymbal_closed, :drum_snare_soft], :drum_cymbal_closed, [:drum_cymbal_closed, :bd_tek], :drum_cymbal_closed, [:bd_tek, :drum_cymbal_closed, :drum_snare_soft], :drum_cymbal_closed, [:bd_tek, :drum_cymbal_closed], :bd_tek, [:drum_snare_soft, :drum_cymbal_closed], :drum_cymbal_closed])
  
end

def test_ois
  a = zparse "4 7 9 1", scale: :chromatic
  assert_equal(a.ois, [0,3,5,9])
  a = zparse "4791", scale: :chromatic
  assert_equal(a[0].ois, [0,3,5,9])
end

def lazy_tests
  tests = [
    "e __6 _0 _1 _2 _3 _4 _5 _6 0 1 2 3 4 5 6 ^0 ^1 ^2 ^3 ^4 ^5 ^6 ^^0",
    "e E T 9 8 7 6 5 4 3 2 1 0 -1 -2 -3 -4 -5 -6 -7 -8 -9 -T -E",
    "[:q 0 1 2 0:] [:q 2 3 h4:] [: [:e 4 5 4 3 q 2 0:] [:q 0 _4 h0:] :]",
    "[: [0 1 2 0] :] [: [[2 3]4] :] [: [: [[4 5][4 3]2 0] :] [: [[0 _4] 0] :] :]",
    "q. 0 0 | q0 e1 q.2 | q2 e1 q2 e3 | h.4 | e 7 7 7 4 4 4 2 2 2 0 0 0 | q4 e3 q2 e1 | h. 0 ",
    "[: q 0 #-1 0 1 2 1 2 3 4 h 4 4 r <q3 h3 3 r q4 h 4 4 r ; q 2 3 h 4 3 2 1 0> :]",
    "[: q 2 2 3 4 | 4 3 2 1 | 0 0 1 2 <q2 1 h1 ; q1 0 h0> :] q 1 1 2 0 | 1 e 2 3 q 2 0 | 1 e 2 3 q 2 1| q0 1h _4 | q 2 2 3 4 |4 3 2 1|0 0 1 2|1 0 h0|",
    "q [: 0 0 4 4 5 5 h4 q 3 3 2 2 1 1 h0 < [:q4 4 3 3 2 2 h1 :] ;  > :]",
    "q [: 0 1 2 :] [: 5 0 5 :3] [: 0 3 :4] _2",
    "e i ii iii iv v vi vii",
    "e [: iv 0 1 2 iii 1 2 3 ii 3 2 1 i 0 1 2 :]",
    "e [:iv 0 1 2 iii 1 2 3 ii 3 2 1 i 0 1 2:]",
    "e [: i^major7 vi^dim ii^m7 v^dim7 :]",
    "e vii%-1 iii vi ii%0 v%0 i%0 iv%0",
    "@(e 0 1 2 1) [: i^7 :]  [: iv^dim :] ",
    "@(e 0 1 e 2 1 0 1) [: i^6 :] [: iv^dim7 :]",
    "@(e 4 3 2 1 0) [: ii^m7 :] [: v^add11%-2 :] [: i^maj9%1 :] vi^m9%-3 vi^m9%-2",
    "@(q 0 012) i^7 v iv ",
    "w 5 [[5 3][3 2 1 0]] 7 2",
    "w 5 q 5 3 e 3 2 1 0 w 7 2",
    "h 1 [0 2 1 3] 2 [[4 2]1 3 1] 5 [6 4[5 3]2] 3 [2 3 1 4]",
    "w [0[1 2[2 3[5]]]]",
    "h 1 [5 3] w 1 [3 1[2 1 0]] -2 [-1 2 [3 4[7 8]]] ^3 _8",
    "q [: ~80 ~50 :]",
    "q ~<0.5>0123",
    "h ~<10.0>0123 ",
    "h2 q 2 1 2 q ~<0.1>2555 h. 4 2 q.. ~<0.14>25 4 h ~<0.1>21221",
    "(0 1 2)+(0 1 2)",
    "(0 1 2)-(2 3 4)",
    "(0 1 2)*(1 2 3)",
    "(0 1 2)<->(3 4 1)",
    "(2 3 4)<>(2 3 2)",
    "(1 2 3)<+>(3 2 1)",
    "(3 4 3)<*>(1 2 3)",
    "(0 1 (2 3))<*>(1 2 3)"
  ]
  
  tests.each_with_index do |m,i|
    print m
    r = zparse m
    r.durations
    r.notes
    r.pcs
  end
  
end

def test_generative
  
  with_random_seed 2345 do
    a = zparse "e (: (0,6) :5)"
    assert_equal(a.pcs, [3,6,1,5,6])
    a = zparse "q % ? % ? % ? % ?"
    assert_equal(a.durations.length,4)
    assert_equal(a.pcs.length,4)
    a = zparse "(: {%>0.5?0:1} :5)"
    assert_equal(a.pcs,[1, 1, 1, 1, 0])
    a = zparse "(: {%>0.5?0..2:(: (4,7) :3)} :5)"
    assert_equal(a.pcs,[6, 5, 4, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2])
  end
  
  a = zparse "[: <q;e> 0 2 :]"
  assert_equal(a.durations,[0.25,0.25,0.125,0.125])
  
  a = zparse "e ( 10..15+2 )", cc: 20
  print a.notes
  assert_equal(a.notes, [10,12,14])
  
  a = zparse "e ( 2..4*2 )", cc: 20
  print a.pcs
  assert_equal(a.notes, [2,4,6,8])
  
  # Tired of fixing these. For some reason Sonic Pi opens these in different encoding
  #  a = zparse "q40 _40 ^40 `40 '40 ´40", midi: true
  #  print a.pcs
  #  assert_equal(a.notes, [40,40,40,40,40,40])
  
  a = zparse "0..5"
  print a.pcs
  assert_equal(a.orig_pcs,[0,1,2,3,4,5])
  
  a = zparse "5..0"
  print a.pcs
  assert_equal(a.orig_pcs,[5,4,3,2,1,0])
  
  a = zparse "0..5+2"
  print a.pcs
  assert_equal(a.orig_pcs,[0,2,4])
  
  a = zparse "5..0+2"
  print a.pcs
  assert_equal(a.orig_pcs,[4,2,0])
  
  a = zparse "5..0*2"
  assert_equal(a.orig_pcs,[8,6,4,2,0])
  
  a = zparse "0..5*2"
  assert_equal(a.orig_pcs,[0,2,4,6,8])
  
  a = zparse "-2..2"
  assert_equal(a.orig_pcs,[-2,-1,0,1,2])
  
  a = zparse "2..-2"
  assert_equal(a.orig_pcs,[2,1,0,-1,-2])
  
  a = zparse "-2..2+2"
  assert_equal(a.orig_pcs,[-2,0,2])
  
  a = zparse "-2..2*2"
  assert_equal(a.orig_pcs,[-2,0])
  
  a = zparse "4..2*2"
  assert_equal(a.orig_pcs,[4,6])
  
  a = zparse "4..2*-2"
  assert_equal(a.orig_pcs,[4,2])
  
  a = zparse "4..-2*2"
  assert_equal(a.orig_pcs,[4,2])
  
end

def test_conditionals
  a = zparse "q (0 2 3){x**2}"
  assert_equal(a.orig_pcs,[0,4,9])
  
  a = zparse "q ((0..5){(x+1)(x-2)(x-2)})$"
  assert_equal(a.orig_pcs,[4,2,0,4,2,0,5,4])
  
  a = zparse "(1 2 r 3 4){2x}"
  assert_equal(a.pcs,[2, 4, nil, 6, 1])
  
  a = zparse "(1 2 <-2> 3 4){2x}"
  assert_equal(a.octaves,[0,0,-2,-1])
  
  a = zparse "((1 2 3)+(2 3 4)){x<3?x:x*3}"
  assert_equal(a.pcs,[2, 5, 1, 5, 1, 4, 1, 4, 0])
  
  
  with_random_seed 35531 do
    
    a = zparse "q ((0..5){((1,6)x**(1,3))(2x)})$"
    assert_equal(a.orig_pcs,[0,4,6,4,3,2,4,1,0,2,4,2,5,0,0])
    
    a = zparse "q ((0..2){((1,6)x**(1,3))(2x)})&"
    assert_equal(a.orig_pcs,[0,4,[3,2]])
    
    a = zparse "q ((0 1 0 1){((1,6)x**(1,3))(2x)})!"
    assert_equal(a.orig_pcs,[0,6])
    
    a = zparse "q (1..10){x%(1,5)==0?x+4:x-4}"
    assert_equal(a.pcs,[4, 6, 6, 1, 1, 3, 3, 5, 5, 0])
  end
  
  with_random_seed 23532 do
    a = zparse "1 {%>0.4?2} <2> 3"
    assert_equal(a.pcs,[1,3])
    assert_equal(a.octaves,[0,2])
    a = zparse "1 {%>0.05?2} <2> 3"
    assert_equal(a.pcs,[1,2,3])
    assert_equal(a.octaves,[0,0,2])
    a = zparse "q (0..10){x%(2,4)==0?x-(1,3):x+(1,3)}"
    assert_equal(a.pcs,[5, 4, 5, 6, 2, 1, 2, 3, 6, 5, 6])
  end
  
end

def test_transforms
  # TODO: Write more tests for transforms
  a = zparse "1..10", amp: tweak(:quint, 0.1,1.0,10)
  assert_equal(tweak(:quint, 0.1,1.0,10),a.vals(:amp).ring)
  a = zparse "1..4", channel: [0,1,2,3].ring
  assert_equal([0,1,2,3],a.vals(:channel))
end

def test_random_chords
  keys = ["C","Cs","D","E","Eb","F","Fs","G","A","Bb"]
  roman = [:i,:ii,:iv,:vi,:iii,:vii]
  
  500.times do
    r = roman.choose
    k = keys.choose
    o = rrand_i 0, 4
    k = (k+o.to_s).to_sym
    # Some scales have bugs in Sonic pi
    s = scale_names.to_a.reject {|v| [:evic,:evic_2].include?(v)}.choose
    #print "Random chord: #{r} #{k} #{s}"
    c = chord_degree r, k, s, 3
    a = zparse "#{r.to_s}", key: k, scale: s
    assert_equal(a.notes[0].is_a?(Array) ? a.notes[0].map{|v| v.round(6) } : [a.notes[0].round(6)],c.notes.map{|v| v.round(6) })
  end
  
end

def test_random_chord_names
  keys = ["C","Cs","D","E","Eb","F","Fs","G","A","Bb"]
  500.times do
    k = keys.choose
    o = rrand_i 0, 4
    k = (k+o.to_s).to_sym
    # TODO: Fix rejected chord names
    n = chord_names.to_a.reject {|v| ["M7","m6*9","M","6*9","mM7"].include?(v)}.choose
    c = chord k, n
    a = zparse "i^#{n.to_s}", key: k
    assert_equal(a.notes[0].is_a?(Array) ? a.notes[0].map{|v| v.round(6) } : [a.notes[0].round(6)],c.notes.map{|v| v.round(6) })
  end
  
end



print "Testing ..."

lazy_tests
test1
test2
test3
test4
test5
test6
test_chords
test_octaves
test_samples
test_ois
test_generative
test_conditionals
test_random_chords
test_random_chord_names
test_transforms

print "All tests passed!"
