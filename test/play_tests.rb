load "~/ziffers/ziffers.rb"

use_synth :piano

Ziffers.debug

use_bpm 400

def testzplay

  # Test octaves
  zplay "e __6 _0 _1 _2 _3 _4 _5 _6 0 1 2 3 4 5 6 ^0 ^1 ^2 ^3 ^4 ^5 ^6 ^^0"

  # Test degrees
  zplay "e E T 9 8 7 6 5 4 3 2 1 0 -1 -2 -3 -4 -5 -6 -7 -8 -9 -T -E"

  # frere jacques
  zplay "[:q 0 1 2 0:] [:q 2 3 h4:] [: [:e 4 5 4 3 q 2 0:] [:q 0 _4 h0:] :]", key: :e, scale: :major

  # Same using list notation
  zplay "w [: [0 1 2 0] :] [: [[2 3]4] :] [: [: [[4 5][4 3]2 0] :] [: [[0 _4] 0] :] :]", key: :e, scale: :major

  # row row
  zplay "q. 0 0 | q0 e1 q.2 | q2 e1 q2 e3 | h.4 | e 7 7 7 4 4 4 2 2 2 0 0 0 | q4 e3 q2 e1 | h. 0 "

  # Test additions: Jericho
  zplay "[: q 0 #-1 0 1 2 1 2 3 4 h 4 4 r <(q3 h3 3 r q4 h 4 4 r) (q 2 3 h 4 3 2 1 0)> :]", key: :b, scale: :minor

  # Ode to joy
  zplay "[: q 2 2 3 4 | q 4 3 2 1 | q 0 0 1 2 <(q2 1 h1) (q1 0 h0)> :] q 1 1 2 0 | q 1 e 2 3 q 2 0 | q 1 e 2 3 q 2 1| q 0 1 h _4 | q 2 2 3 4 | q 4 3 2 1| q 0 0 1 2| q 1 0 h0|"

  # twinkle twinkle
  zplay "q [: 0 0 4 4 5 5 h4 q 3 3 2 2 1 1 h0 <(:q4 4 3 3 2 2 h1:) r> :]"

  # Numbered loops
  zplay "q [: 0 1 2 :] [: 5 0 5 :3] [: 0 3 :4] _2"

end

def testchords
  # Chord synth test
  zplay "e i ii iii iv v vi vii", chord_name: "major", chord_duration: 0.15, chord_synth: :piano
  zplay "e i ii iii iv v vi vii", chord_name: "minor", chord_duration: 0.15, chord_synth: :piano
  zplay "[: e iv 0 1 2 iii 1 2 3 ii 3 2 1 i 0 1 2 :]", chord_key: :e3, key: :e3, scale: "mixolydian", chord_duration: 0
  zplay "[: e iv 0 1 2 iii 1 2 3 ii 3 2 1 i 0 1 2:]", chord_key: "f", key: "e", scale: "mixolydian", chord_duration: 0
  zplay "[: e i^major7 vi^dim ii^m7 v^dim7 :]", chord_duration: 0.4, scale: :mixolydian
  zplay "e vii%-1 iii vi ii%0 v%0 i%0 iv%0", chord_duration: 0.4
  zplay "([: i^7 :]  [: iv^dim :])@(e 0 1 2 1)"
  zplay "([: i^6 :] [: iv^dim7 :])@(e 0 1 e 2 1 0 1)", key: :d3, scale: :mixolydian
  zplay "([: ii^m7 :] [: v^add11%-2 :] [: i^maj9%1 :] vi^m9%-3 vi^m9%-2)@(e 4 3 2 1 0)", key: :e2
  zplay "(i^7 v iv)@(q 0 012)"
end

def testcontrolchars
  with_synth :beep do
    zplay "q S2 0 2 4"
    zplay "q R4 7"
  end
end

## TODO: Write better tests for generative syntax and sets
def testrandom
  zplay "e 0..11"
  sleep 0.5
  zplay "e (0..11)~"
  sleep 0.5
  zplay "e ( (100,1000) :3)<r>"
  sleep 0.5
  zplay "e (0..2)<m>"
  sleep 0.5
  zplay "e (0..6)?"
  sleep 0.5
  zplay "e (0..6)?2"
  sleep 0.5
  zplay "e (0..6)~2*2"
  sleep 0.5
  zplay "e ((0,6))+1*2/3%7"
  sleep 0.5
  zplay "e (w q q e e)<>((1000,4000))"
  sleep 0.5
  zplay "e (w q q e e e)<>(0..8)"
  sleep 0.5
  zplay "e (w q q e e e)<>(0..8)~"
  sleep 0.5
  zplay "q (q e e)<>(: 100..1000 :3)?5$"
  sleep 0.5
  zplay "(q e e)<>(: 100..1000 :3)?5&"
  sleep 0.5
  zplay "(e q e)<>(: 0..4 :4)~2+1*3"

end

def testslide
  # TODO: Some timing problems with the slide?
  with_synth :chiplead do
    zplay "q [: ~80 ~50 :]"
    zplay "q ~<0.5>0123"
    zplay "h ~<10.0>0123 "
    zplay "h2 q 2 1 2 q ~<0.2>255 h. 4 2 q.. ~<0.2>255 4 h ~<0.3>2121"
  end
end

def testzsample
  zplay "[:q 0 1 2 0:][:q 2 3 h4:][:[:e 4 5 4 3 q.2 q0 :][:q 0 _4 h0:]:]", sample: :ambi_drone, key: :c4, sustain: 0.25
  zplay "[:q 0 1 2 0:][:q 2 3 h4:][:[:e 4 5 4 3 q.2 q0 :][:q 0 _4 h0:]:]", sample: :ambi_drone, key: :c4, sustain: 0.25, rate_based: true
  # TODO: Fix
  # zplay "h2 q 2 1 2 q ~2555 h. 4 2 q.. ~25555 4 h ~<4.0>21111111222222211111", sample: :ambi_piano, sustain: 0.25, key: "c", amp: 2
  zplay " q 0 0 4 4 5 5 h4 q 3 3 2 2 1 1 h 0 ", sample: :ambi_glass_rub, rate: 2.0, amp: 0.5
end

def testsingledegrees
  (scale :gong).reflect.each do |k|
    [1,3,6].each do |d|
      zplay d, key: 40+k, scale: :blues_minor, duration: 0.125
    end
  end
end

def testarraydegrees
  zplay [3,3,2,2,1,1,2,2,3,3,2,2,1,1,2,2], key: :c, scale: :chromatic, duration: 0.125
  zplay [[0, 0.5], [0, 0.5], [0, 1], [1, 1]], scale: :aeolian
  zplay [0,2,4,5,6,7].zip(0.1.step(2.0,0.1).to_a), duration: 0.125
end

def test_string_rewrite_system
  with_synth :beep do
    zplay "q 0", rules: {"0"=>"0 2","2"=>"5 3 2 0"}, gen: 3
    zplay "q?", rules: {"q?"=>"q? e ? ? ? q?"}, gen: 2, scale: :major_pentatonic
    zplay "q1", rules: {/[a-z][0-6]/=>"(q e q q e)<>(0..6)~"}, gen: 2, scale: :gong
    zplay "q1", rules: {/(3)1/=>"q =($1+1) 1 =($2+2)",/[1-7]/=>"e 3 1 3"}, gen: 3
    # TODO: Fix these?
    # zplay "q 1 2 3", rules: {/[1-9]/=>"'$*1' {e,q} '$*2'"}, gen: 4
    # zplay "q 1 1 1 ", rules: {/(?<= ([1-9]) ([1-9]) )/=>"0.6%=<?=(-3,3)>' $1+?' '$2+?' "}, gen: 4
  end
end

def testSimult
  zplay "q 024 0 2 4 310 3 1 4 346 6 4 3 024"
  zplay "q [: q HB H BHS H :2] q BH B q SH H "*1,
  use: {
    B: :bd_tek,
    S: :drum_snare_soft,
    H: {sample: :drum_cymbal_closed, amp: 0.2}
  }
end

def testListSyntax
  zplay "w 5 [[5 3][3 2 1 0]] 7 2"
  zplay "w 5 q 5 3 e 3 2 1 0 w 7 2"
  zplay "h 1 [0 2 1 3] 2 [[4 2]1 3 1] 5 [6 4[5 3]2] 3 [2 3 1 4] "
  zplay "w [0[1 2[2 3[5]]]]"
  zplay "h 1 [5 3] w 1 [3 1[2 1 0]] -2 [-1 2 [3 4[7 8]]] ^3 _8"
end

def testUseChars
  zplay "q A2 X O e X X q O", use: {"X": :bd_tek, "O": :drum_snare_soft}
  zplay "q [: X O e X X q O :]", use: {"X": {note: 40, port: "loopmidi", channel: 8}, "O": {note: 30, port: "loopmidi", channel: 8}}
  zplay "q [: O X X X X :]", use: {"X": :bd_tek, "O": {sample: :ambi_choir, rate: 0.2, duration: 0}}
end

def testpreparse
  zplay "q [:[c d e c]:][:[[e f] g]:]", parsekey: :c, key: :e
end

def testeffects
  zplay "Z4 B", use: {"B": :misc_cineboom, run:[{with_fx: :echo}]}
  zplay "q 0 1 2 3 4 3 2 1", run: [{with_fx: :echo}]
  zplay "q 0 1 F 2 3 4 2 ! 3 1 3 2 1", use: {"F": {run:[{with_fx: :echo}]}}
end

def testadjust
  zplay "q 0 1 3 2 4 5 6 7 8 9", pan: ->(){rrand_i(-1,1)}
  zplay "q 0 1 2 3 4 5 6 7 8 9", amp: (tweak :circ, 0, 1, 10).ring.mirror
end



testzplay
testchords
testcontrolchars
test_string_rewrite_system
testrandom
testslide
testzsample
testsingledegrees
testarraydegrees
testSimult
testListSyntax
testUseChars
testpreparse
testeffects
testadjust
