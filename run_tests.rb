
require "~/ziffers/ziffers.rb"

# Todo: Add more tests

def test1
  
  m1 = zparse("|:q.1.1|q1e2q.3|3e2q3e4|h.5|e888555333111|q5e4q3e2|h.1:|")
  m1_2 = zparse "|:1/4 1231:|:34 2/4 5:|@:1/8 5654 1/4 31:|:1 _5^ 2/4 1:@|", key: :e, scale: :major
  m1_3 = zparse "|:(1231):|:((34)5):|@:((56)(54)31):|:((1_5)^1):@|", key: :e, scale: :major
  
  m1_s = zparams(m1,:sleep)
  m1_n = zparams(m1,:note)
  m1_2_s = zparams(m1_2,:sleep)
  m1_2_n = zparams(m1_2,:note)
  m1_3_s = zparams(m1_3,:sleep)
  m1_3_n = zparams(m1_3,:note)
  m1_n_assert = [0.375, 0.375, 0.25, 0.125, 0.375, 0.25, 0.125, 0.25, 0.125, 0.75, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.25, 0.125, 0.25, 0.125, 0.75, 0.375, 0.375, 0.25, 0.125, 0.375, 0.25, 0.125, 0.25, 0.125, 0.75, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.25, 0.125, 0.25, 0.125, 0.75]
  m1_s_assert = [60, 60, 60, 62, 64, 64, 62, 64, 65, 67, 72, 72, 72, 67, 67, 67, 64, 64, 64, 60, 60, 60, 67, 65, 64, 62, 60, 60, 60, 60, 62, 64, 64, 62, 64, 65, 67, 72, 72, 72, 67, 67, 67, 64, 64, 64, 60, 60, 60, 67, 65, 64, 62, 60]
  
  assert_equal(m1_s, m1_n_assert)
  assert_equal(m1_n, m1_s_assert)
  
end

def test2
  
  m2 = zparse("|:q1231:|:q34h5:|@:e5654q31:|:q1_5^h1:@|", key: :e, scale: :major)
  m2_s = zparams(m2,:sleep)
  m2_n = zparams(m2,:note)
  
  assert_equal(m2_s,[0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5])
  assert_equal(m2_n,[64, 66, 68, 64, 64, 66, 68, 64, 68, 69, 71, 68, 69, 71, 71, 73, 71, 69, 68, 64, 71, 73, 71, 69, 68, 64, 64, 71, 64, 64, 71, 64, 71, 73, 71, 69, 68, 64, 71, 73, 71, 69, 68, 64, 64, 71, 64, 64, 71, 64])
  
end

def test3
  m3_1 = zparse "w 6 ((64)(4321)) 83"
  m3_2 = zparse "w 6 q64 e4321 w 83"
  m3_1_s = zparams(m3_1,:sleep)
  m3_2_s = zparams(m3_2,:sleep)
  assert_equal(m3_1_s,m3_2_s)
  
  m4 = zparse "w ((34)1(23(34(6(34)))))"
  m4_s = zparams(m4,:sleep)
  assert_equal(m4_s,[0.16666666666666666, 0.16666666666666666, 0.3333333333333333, 0.1111111111111111, 0.1111111111111111, 0.037037037037037035, 0.037037037037037035, 0.018518518518518517, 0.009259259259259259, 0.009259259259259259])
  
end

def test4
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
  t5 = zparse "q987654321-1-2-3-4-5-6-7-8-9", key: :c
  t5n = zparams t5, :note
  assert_equal(t5n,[74, 72, 71, 69, 67, 65, 64, 62, 60, 59, 57, 55, 53, 52, 50, 48, 47, 45])
end

test1
test2
test3
test4
test5

print "All tests passed!"
