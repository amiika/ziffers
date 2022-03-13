load "~/ziffers/ziffers.rb"

Ziffers.debug

def test_play

  # Multistaff

  a = parse_rows "
/ synth: :pretty_bell
[:q 2 2 2 4 q. 4 e 3 h 2 q 2 1 2 4 q. 2 e 1 h 0 :] [: 4 e 5 4 3 2 h 3 e 4 3 2 1 h 2 e 3 2 1 0 q. 1 e _ 4 h 4 q ^ 0 1 2 3 h 2 1 :]
[: q 0 0 _ 6 6 ^ 1 _ 6 h ^ 0 q 0 _ 6 ^ 0 0 0 _ 6 h ^ 0 :] [: q 0 e 2 1 h 0 q 0 e 1 0 h _ 6 q 6 e ^ 0 _ 6 h 5 q. 4 e 4 h 4 q 4 6 ^ 0 0 h 0 _ 6 :]
[: q 4 4 4 4 5 4 h 4 q 4 4 4 4 q. 4 e 3 h 2  :] [: h 2 5 5 4 4 3 q 1 0 h _ 6 q 6 ^ 4 4 5 h 4 4 :] / octave: -1,
[: q 0 0 2 2 1 _ 4 h ^ 0 q 0 _ 4 ^ 0 _ 2 4 4 h ^ 0 :] [: h 0 q _ 5 ^ 0 h 1 q _ 4 6 h ^ 0 q _ 3 5 6 r 4 r 2 4 r 3 h 0 4 :] / octave: -1
"
  assert_equal(a[:rows].length,4)

  a = parse_rows "
/ synth: :kalimba
h H X / X: :bd_808, H: {sample: :drum_cowbell, amp: 0.025}
h0 h. 2 q 2 h 1 0 3 3 2 1 2 4 4 #3 w. 4 h 2 h. 5 q 4 h 3 2 1 0 _6 2 1 0 0 _6 w. 0 / octave: 1
h4 h. ^ 0 q 0 h _ 6 5 q 5 6 ^ 0 1 h 0 _ 6 4 q 6 ^ 0 h 1 1 _6 1 0 0 h. 0 q 0 h 0 0 _ 1 q 2 3 h 4 4 6 5 5 4 w. 4
h2 h. 4 q 4 h 4 q 5 4 h 3 5 4 4 2 q 4 5 h 5 5 4 6 5 4 h. 3 q 4 h 3 4 _6 0 1 2 q 4 3 h 2 3 q 4 3 w. 2
h0 q 0 _ 6 h 5 4 5 3 q 5 6 h ^0 4 ^ 0 0 1 1 w. _4 h 0 h. _ 3 q 3 h 1 q 2 3 h 4 5 4 ^0 4 5 3 4 w. ^ 0
"
  assert_equal(a[:rows].length,5)

  a = parse_rows "
/ synth: :piano
|[: q 2 2 1 0  | h _ 6 5  | q 2 2 #3 #4  | h 5 #4  | q 5 ^ 0 q. _ 6 e 5  | w 5 :] | \
| q 2 2 3 2  | q. 1 e 0 h 0  | q 2 #3 4 2  | q 5 4 h #3  | h 2 q 2 2  | q 1 0 h _ 6  | w _ 5  |

/ synth: :blade
|[: q 0 e 0 _ 6 q 5 5  | q _ 5 #4 h 2  | q _ 5 5 5 6  | q _ 5 6 h 6  | q _ 5 ^ 2 h 1  | w 0 :] | \
| q _ 5 6 5 5  | h _ 6 5  | q _ 5 5 e 6 5 q 4  | q 0 _ 6 h 5  | h _ 4 q 5 5  | q _ 5 5 5 #4  | w _ 2  |

/ synth: :kalimba
|[: q _ 5 4 3 2  | q _ 3 e 2 1 h 0  | e _ 0 1 q 2 e 1 2 q 3  | q _ 2 3 h 2  | q _ 2 5 h #4  | w _ 2 :] | \
| q _ 0 1 0 e 0 1  | h _ 2 2  | q _ 0 0 1 e 0 1  | q _ 2 2 1 0  | h __ 6 e ^ 0 1 q 2  | q _ 1 2 3 e 2 1  | w _ 0  |

/ synth: :pluck
|[: e __ 5 6 q ^ 0 e _ 3 4 q 5  | q __ 1 2 h 5  | e __ 5 6 q ^ 0 1 1  | q _ #0 #1 h 2  | e _ 0 _ 6 q 5 ^ 2 _ 2  | w __ 5 :] | \
| q __ 5 #4 5 5  | h __ 4 5  | q __ 5 5 4 0  | q __ 0 0 h 1  | h __ 2 e 5 6 q ^ 0  | e __ 3 4 q 5 1 3  | w ___ 5  |
"
  assert_equal(a[:rows].length,4)

end

def test_methods
  a = zparse "[: q 0 :foo :bar(2) :3] 7"
  assert_equal(a.vals(:method),[nil, "foo", "bar(2)", nil, "foo", "bar(2)", nil, "foo", "bar(2)", nil])
end

test_play
test_methods

print "All tests OK"
