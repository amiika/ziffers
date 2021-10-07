load "~/ziffers/ziffers.rb"

# Todo: Add more tests

def test1

  # Test different timing notations

  m1 = zparse("|:q.0 .0|q0 e1 q.2 |2e 1q 2 e3|h.4|e7 7 7 4 4 4 2 2 2 0 0 0|q4 e3 q2 e1 |h.0:|")

  m1_s = zparams(m1,:sleep)
  m1_n = zparams(m1,:note)
  m1_n_assert = [0.375, 0.375, 0.25, 0.125, 0.375, 0.25, 0.125, 0.25, 0.125, 0.75, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.25, 0.125, 0.25, 0.125, 0.75, 0.375, 0.375, 0.25, 0.125, 0.375, 0.25, 0.125, 0.25, 0.125, 0.75, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.25, 0.125, 0.25, 0.125, 0.75]
  m1_s_assert = [60, 60, 60, 62, 64, 64, 62, 64, 65, 67, 72, 72, 72, 67, 67, 67, 64, 64, 64, 60, 60, 60, 67, 65, 64, 62, 60, 60, 60, 60, 62, 64, 64, 62, 64, 65, 67, 72, 72, 72, 67, 67, 67, 64, 64, 64, 60, 60, 60, 67, 65, 64, 62, 60]

  assert_equal(m1_s, m1_n_assert)
  assert_equal(m1_n, m1_s_assert)

end

def test2

  # Test loops and octaves etc.

  m2 = zparse("|:q0 1 2 0:|:q2 3 h4:|@:e4 5 4 3 q2 0:|:q0 _4 ^h0:@|", key: :e, scale: :major)
  m2_s = zparams(m2,:sleep)
  m2_n = zparams(m2,:note)

  assert_equal(m2_s,[0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5])
  assert_equal(m2_n,[64, 66, 68, 64, 64, 66, 68, 64, 68, 69, 71, 68, 69, 71, 71, 73, 71, 69, 68, 64, 71, 73, 71, 69, 68, 64, 64, 71, 64, 64, 71, 64, 71, 73, 71, 69, 68, 64, 71, 73, 71, 69, 68, 64, 64, 71, 64, 64, 71, 64])

end

def test3

  # Test list notation

  m3_1 = zparse "w 5 ((5 3)(3 2 1 0)) 7 2"
  m3_2 = zparse "w 4 q5 3 e 3 2 1 0 w 7 2"
  m3_1_s = zparams(m3_1,:sleep)
  m3_2_s = zparams(m3_2,:sleep)
  assert_equal(m3_1_s,m3_2_s)

  m4 = zparse "w ((2 3) 0 (1 2 (2 3 ( 5 (2 3)))))"
  m4_s = zparams(m4,:sleep)
  assert_equal(m4_s,[0.16666666666666666, 0.16666666666666666, 0.3333333333333333, 0.1111111111111111, 0.1111111111111111, 0.037037037037037035, 0.037037037037037035, 0.018518518518518517, 0.009259259259259259, 0.009259259259259259])

end

def test4

  # Test some chords

  t4 = zparse "i", key: :d, scale: :major
  t4_n = zparams(t4,:notes)[0].to_a
  assert_equal(t4_n,(chord_degree :i, :d, :major, 3).to_a)

  t4_2 = zparse "i/1", key: :d, scale: :major
  t4_2_n = zparams(t4_2,:notes)[0].to_a
  assert_equal(t4_2_n,(chord_degree :i, :d, :major, 1).to_a)

  t4_3 = zparse "i^maj*2", key: :d, scale: :major
  t4_3_n = zparams(t4_3,:notes)[0].to_a
  assert_equal(t4_3_n,(chord :d, :major, num_octaves: 2).to_a)

end

def test5

  # Test negative degrees

  t5 = zparse "sET9876543210-1-2-3-4-5-6-7-8-9-T-E", groups: false
  t5n = zparams t5, :note
  print t5n
  assert_equal(t5n,[79, 77, 76, 74, 72, 71, 69, 67, 65, 64, 62, 60, 59, 57, 55, 53, 52, 50, 48, 47, 45, 43, 41])
end

def test6

  # Test lsystem

  # String replacement
  t6_1 = lsystem "0", {"0"=>"1", "1"=>"2", "2"=>"0"}, 4, nil
  assert_equal(t6_1,["1", "2", "0", "1"])

  # Regexp with '' eval syntax
  t6z_1 = zparse "q0 e0 1 2 3", rules: {/(?<=q)[0-9]/=>"'$+1'"}, gen: 3
  t6_2 = zparams(t6z_1, :degree)
  assert_equal(t6_2,[3, 0, 1, 2, 3])

  # Regexp with lambda
  t6z_2 = zparse "q1 e3 q4", gen: 3, groups: false, rules: {
    /([a-z])([1-9]*)/=> ->(i,m){ print m; m[1]+(m[2].to_i*2).to_s }
  }
  t6_3 = zparams(t6z_2,:degree)
  assert_equal(t6_3, [8, 2, 4, 3, 2])

end

test1
test2
test3
test4
test5
test6

print "All tests passed!"
