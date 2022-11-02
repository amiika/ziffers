def test_chords
  # Chords
  a = zparse "[: i vi v :]" # Play chords as a sequence using default chord length of 1
  assert_equal(a.pcs,[[0, 2, 4], [5, 0, 2], [4, 6, 1], [0, 2, 4], [5, 0, 2], [4, 6, 1]])
  a = zparse "q [: iv 1 2 3 iii 2 3 4 ii 4 3 2 i 1 2 3 :]", chord_duration: 0 # Play chord simultaniously with the melody using **chord_duration**
  assert_equal(a.pcs,[[3, 5, 0], 1, 2, 3, [2, 4, 6], 2, 3, 4, [1, 3, 5], 4, 3, 2, [0, 2, 4], 1, 2, 3, [3, 5, 0], 1, 2, 3, [2, 4, 6], 2, 3, 4, [1, 3, 5], 4, 3, 2, [0, 2, 4], 1, 2, 3])
  a = zparse "i"   # Plays trichord
  assert_equal(a.pcs,[[0, 2, 4]])
  a = zparse "i+1" # Plays root
  assert_equal(a.pcs,[0])
  a = zparse "i+4" # Plays 7th chord
  assert_equal(a.pcs,[[0, 2, 4, 6]])
  a = zparse "i+5" # Plays 9th chord
  assert_equal(a.pcs,[[0, 2, 4, 6, 1]])
  a = zparse "i+24" # Plays chord in multiple octaves
  assert_equal(a.pcs,[[0, 2, 4, 6, 1, 3, 5, 0, 2, 4, 6, 1, 3, 5, 0, 2, 4, 6, 1, 3, 5, 0, 2, 4]])

  # Chord names
  a = zparse "i vi", chord_name: :dim
  assert_equal(a.pcs,[[0, 2, 3], [5, 0, 2]])
  a = zparse "i vi^dim"
  assert_equal(a.pcs,[[0, 2, 4], [5, 0, 2]])
  a = zparse "i^7*2" # Plays chord in 2 octaves
  assert_equal(a.pcs,[[0, 2, 4, 6, 0, 2, 4, 6]])
  a = zparse "i vi", chord_name: "m11+"
  assert_equal(a.pcs,[[0, 2, 4, 6, 1, 3], [5, 0, 2, 4, 6, 2]])
  a = zparse "i vi^m11+"
  assert_equal(a.pcs,[[0, 2, 4], [5, 0, 2, 4, 6, 2]])
  a = zparse "i^maj*2" # Plays chord in two octaves
  assert_equal(a.pcs,[[0, 2, 4, 0, 2, 4]])
  a = zparse "vii%-2 iii%-1 vi%-1 ii v i%1 iv%2", chord_duration: 0.25, key: :d, scale: :minor
  assert_equal(a.pcs,[[1, 3, 6], [6, 2, 4], [2, 5, 0], [1, 3, 5], [4, 6, 1], [2, 4, 0], [0, 3, 5]])

  # Arpeggios
  a = zparse "@(q 1 2 3 1) i ii iii iv v vi vii"
  assert_equal(a.pcs,[[0, 2, 4], [1, 3, 5], [2, 4, 6], [3, 5, 0], [4, 6, 1], [5, 0, 2], [6, 1, 3]])
  a = zparse "@(q 0 1 e 2 1 0 1) [: i^7 :3][: iv^dim7%-1 :3]", key: :d4, scale: :mixolydian
  assert_equal(a.pcs,[[0, 2, 4, 5], [0, 2, 4, 5], [0, 2, 4, 5], [1, 3, 4, 6], [1, 3, 4, 6], [1, 3, 4, 6]])
  a = zparse "@(q 0 123) [: i^7 :4][: iv%-1 :4]"
  assert_equal(a.pcs,[[0, 2, 4, 6], [0, 2, 4, 6], [0, 2, 4, 6], [0, 2, 4, 6], [0, 3, 5], [0, 3, 5], [0, 3, 5], [0, 3, 5]])

end

def test_cycles
 # TODO: Currently loop counters are not testable
 a = zparse "<0 3 5 3>"
 assert_equal(a.pcs,[0])

 a = zparse "(: <0 3 5 3> :3)"
 assert_equal(a.pcs,[0,3,5])
 a = zparse "(: <0 <3 5 3>> :4)"
 assert_equal(a.pcs,[0,3,0,5])
 a = zparse "(<0 1 2> <3 2>)<2,6>(1)"
 assert_equal(a.pcs,[0,1,1,3,1,1])

 a = zparse "(<0 1 2> <3 2>)<~2,6~>(1)"
 assert_equal(a.pcs,[0,1,1,3,1,1])
 a = zparse "(<0 1 2> <3 4>)<~3,6~>(<5 6>)"
 assert_equal(a.pcs,[0,5,3,6,1,5])
 a = zparse "(<0 1 2> <3 4>)<3,6~>(<5 6>)"
 assert_equal(a.pcs,[0,5,3,6,0,5])
 a = zparse "(<0 1 2> <3 4>)<3,6>(<5 6>)"
 assert_equal(a.pcs,[0,5,3,5,0,5])
 a = zparse "(<1 <2 <3 4>>>)<~4,8~>(5 <6 <7 8>>)"
 assert_equal(a.pcs,[1,5,2,6,1,5,3,0])
 a = zparse "(<1 <2 <3 4>>>)<~4,8>(5 <6 <7 8>>)"
 assert_equal(a.pcs,[1,5,2,6,1,5,3,6])
 a = zparse "(<0 1 <2 4>>)<1,7~>(<1 2 <3 4>>)"
 assert_equal(a.pcs,[0,1,2,3,1,2,4])
 a = zparse "(0 1 2 4)<1,4>(4 5 6 1)"
 assert_equal(a.pcs,[0,4,5,6])

 a = zparse "<(1 2 3)<1,5~>(4 (1,5) 6) (1 <2 3> 2)<2,5~>(<4 5 6>)>"
 assert_equal(a.pcs,[1,4,4,6,4])
 a = zparse "<(1 2 3)<1,5~>((4)<1,2>(3) 4 (1,5) 6) (1 <2 3> 2)<2,5~>(<4 5 6>)>"
 assert_equal(a.pcs,[1,4,3,4,3,6])

end

test_chords
test_cycles

print "All tests OK"
