load "~/ziffers/ziffers.rb"

# Todo: Add more tests

def test1
  
  # Test different timing notations
  
  m1 = zparse("[: q. 0 0 | q0 e1 q.2 |q2 e1 q2 e3| h.4 | 0.125 7 7 7 4 4 4 2 2 2 0 0 0| q4 e3 q2 e1 | h.0 :]")
  
  print m1
  
  m1_s = zparams(m1,:sleep)
  m1_n = zparams(m1,:note)
  m1_n_assert = [0.375, 0.375, 0.25, 0.125, 0.375, 0.25, 0.125, 0.25, 0.125, 0.75, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.25, 0.125, 0.25, 0.125, 0.75, 0.375, 0.375, 0.25, 0.125, 0.375, 0.25, 0.125, 0.25, 0.125, 0.75, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.25, 0.125, 0.25, 0.125, 0.75]
  m1_s_assert = [60, 60, 60, 62, 64, 64, 62, 64, 65, 67, 72, 72, 72, 67, 67, 67, 64, 64, 64, 60, 60, 60, 67, 65, 64, 62, 60, 60, 60, 60, 62, 64, 64, 62, 64, 65, 67, 72, 72, 72, 67, 67, 67, 64, 64, 64, 60, 60, 60, 67, 65, 64, 62, 60]
  
  assert_equal(m1_s, m1_n_assert)
  assert_equal(m1_n, m1_s_assert)
  
end

def test2
  
  # Test loops and octaves etc.
  
  m2 = zparse("[:q _ 0 1 (-1) 2 (0)0:][: 2 3 h4:][:[:e 4 5 4 3 q 2 0:][:0 _4 h0:]:]", key: :e, scale: :major)
  print m2
  m2_s = zparams(m2,:sleep)
  m2_n = zparams(m2,:note)
  print m2_n
  assert_equal(m2_s,[0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5])
  assert_equal(m2_n, [52, 54, 56, 64, 52, 54, 56, 64, 56, 57, 59, 56, 57, 59, 59, 61, 59, 57, 56, 52, 59, 61, 59, 57, 56, 52, 52, 47, 52, 52, 47, 52, 59, 61, 59, 57, 56, 52, 59, 61, 59, 57, 56, 52, 52, 47, 52, 52, 47, 52])
end

def test3
  
  # Test list notation
  
  m3_1 = zparse "w 5 ((5 3)(3 2 1 0)) 7 2"
  m3_2 = zparse "w 5 q 5 3 e 3 2 1 0 w 7 2"
  m3_1_s = zparams(m3_1,:sleep)
  m3_2_s = zparams(m3_2,:sleep)
  
  assert_equal(m3_1_s,m3_2_s)
  
  m4 = zparse "((2 3) 0 (1 2 (2 3 ( 5 (2 3)))))"
  m4_s = zparams(m4,:sleep)
  assert_equal(m4_s,[0.16666666666666666, 0.16666666666666666, 0.3333333333333333, 0.1111111111111111, 0.1111111111111111, 0.037037037037037035, 0.037037037037037035, 0.018518518518518517, 0.009259259259259259, 0.009259259259259259])
  
end

def test4
  
  # Test some chords
  
  t4 = zparse "i", key: :d, scale: :major
  t4_n = zparams(t4,:notes)[0].to_a
  assert_equal(t4_n,(chord_degree :i, :d, :major, 3).to_a)
  
  
  t4_2 = zparse "i+1", key: :d, scale: :major
  t4_2_n = zparams(t4_2,:notes)[0].to_a
  assert_equal(t4_2_n,(chord_degree :i, :d, :major, 1).to_a)
  
  t4_3 = zparse "i^maj*2", key: :d, scale: :major
  t4_3_n = zparams(t4_3,:notes)[0].to_a
  assert_equal(t4_3_n,(chord :d, :major, num_octaves: 2).to_a)
  
  t4_4 = zparse "_1^#1__b1"
  assert_equal(t4_4.notes.flatten,[50,75,37])
  
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
  t6z_1 = zparse "q0 e0 1 2 3", rules: {/(?<=q)[0-9]/=>"=($+1)"}, gen: 3
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
  
  to2 = zparse "0 (1) 2 (-2) 2 (3)1"
  assert_equal(to2.octaves,[0, 1, -2, 3])
end

def test_samples
  a = zparse "A q B e A A", A: :ambi_dark_woosh, B: :ambi_sauna
  assert_equal(a.samples, [:ambi_dark_woosh, :ambi_sauna, :ambi_dark_woosh, :ambi_dark_woosh])
  assert_equal(a.durations, [1.0, 0.25, 0.125, 0.125])
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
    "[: (0 1 2 0) :] [: ((2 3)4) :] [: [: ((4 5)(4 3)2 0) :] [: ((0 _4) 0) :] :]",
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
    "w 5 ((5 3)(3 2 1 0)) 7 2",
    "w 5 q 5 3 e 3 2 1 0 w 7 2",
    "h 1 (0 2 1 3) 2 ((4 2)1 3 1) 5 (6 4(5 3)2) 3 (2 3 1 4)",
    "w (0(1 2(2 3(5))))",
    "h 1 (5 3) w 1 (3 1(2 1 0)) -2 (-1 2 (3 4(7 8))) ^3 _8",
    "q [: ~80 ~50 :]",
    "q ~<0.5>0123",
    "h ~<10.0>0123 ",
    "h2 q 2 1 2 q ~<0.1>2555 h. 4 2 q.. ~<0.14>25 4 h ~<0.1>21221"
  ]
  
  tests.each_with_index do |m,i|
    print m
    r = zparse m
    r.durations
    r.notes
    r.pcs
  end
  
end


#TODO

def test_generative
  
  with_random_seed 2345 do
    a = zparse "e {: (0,6) :5}"
    assert_equal(a.pcs, [3,6,1,5,6])
  end
  
  a = zparse "e { 10..15+2 }", cc: 20
  print a.notes
  assert_equal(a.notes, [10,12,14])
  
  a = zparse "e { 2..4*2 }", cc: 20
  print a.notes
  assert_equal(a.notes, [2,4,6,8])
  
  a = zparse "q40 _40 ^40 `40 '40 ´40", midi: true
  assert_equal(a.notes, [40,40,40,40,40,40])
  
  a = zparse "0..5"
  assert_equal(a.orig_pcs,[0,1,2,3,4,5])
  
  a = zparse "5..0"
  assert_equal(a.orig_pcs,[5,4,3,2,1,0])
  
  a = zparse "0..5+2"
  assert_equal(a.orig_pcs,[0,2,4])
  
  a = zparse "5..0+2"
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
  a = zparse "q {0 2 3}(x^2)"
  assert_equal(a.orig_pcs,[0,4,9])
  a = zparse "q {{0..5}((x+1)(x-2)(x-2))}$"
  assert_equal(a.orig_pcs,[4,2,0,4,2,0,5,4])
  with_random_seed 35531 do
    a = zparse "q {{0..5}(((1,6)x^(1,3))(2x))}$"
    assert_equal(a.orig_pcs,[0,4,6,4,3,2,4,1,0,2,4,2,5,0,0])
    a = zparse "q {{0..2}(((1,6)x^(1,3))(2x))}&"
    assert_equal(a.orig_pcs,[0,4,[3,2]])
    a = zparse "q {{0 1 0 1}(((1,6)x^(1,3))(2x))}!"
    assert_equal(a.orig_pcs,[0,6])
  end
end

print "Testing"
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


print "All tests passed!"
