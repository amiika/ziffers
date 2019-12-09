load "~/ziffers/ziffers.rb"

use_synth :piano

Ziffers.debug
Ziffers.set_default_opts({amp: 0.5})

def testzplay
  # Test all degrees
  zplay "s0123456789TET9876543210", groups: false
  # Test negative degrees
  zplay "sET9876543210-1-2-3-4-5-6-7-8-9-T-E", groups: false
  # frere jacques
  zplay "|:q0 1 2 0:|:q 2 3 h4:|@:e4 5 4 3 q2 0:|:q0 _4 ^h0:@|", key: :e, scale: :major
  # Same using list notation
  zplay "|:(0 1 2 0):|:((2 3)4):|@:((4 5)(4 3)2 0):|:((0 _4)^0):@|", key: :e, scale: :major
  # row row
  zplay "|:q .0 .0|q0 e1 q.2|2 e1 q2 e3|h.4|e7 7 7 4 4 4 2 2 2 0 0 0|q4 e3 q2 e1|h.0:|"
  # jericho
  zplay "|:q0 _6 ^0 1 b2 1 b2 3 4 h4 4 r ;q3 h3 3 r q4 h4 4 r; q b2 3 h4 3 b2 1 0:|", key: :d, scale: :major
  # ode to joy
  zplay "|:q2 2 3 4|4 3 2 1|0 0 1 2|;q2 1 h1;q1 0 h0:|q1 1 2 0|1 e2 3 q2 0|1 e2 3 q2 1|q0 1h _4|^q2 2 3 4|4 3 2 1|0 0 1 2|1 0 h0|"
  # twinkle twinkle
  zplay "q0 0 4 4 5 5 h4 q3 3 2 2 1 1 h0 *|: q4 4 3 3 2 2 h1 :|*"
  # Numbered loops
  zplay "|:q0 1 2 3:2| 5 0 5 |:3 2 1 0:2|"
end

def testchords
  # Chord synth test
  zplay "G'e0 123' |: i^6 :3||: %-0 iv :3|"
  zplay "i ii iii iv v vi vii", chord_name: "major", chord_sleep: 0.15, chord_synth: :piano
  zplay "i ii iii iv v vi vii", chord_name: "minor", chord_sleep: 0.15, chord_synth: :piano
  zplay "|:iv 0 1 2 iii 1 2 3 ii 3 2 1 i 0 1 2:|", chord_key: :e3, key: :e3, scale: "mixolydian", chord_sleep: 0, sleep: 0.14
  zplay "|:iv 0 1 2 iii 1 2 3 ii 3 2 1 i 0 1 2:|", chord_key: "f", key: "e", scale: "mixolydian", chord_sleep: 0, sleep: 0.14
  zplay "|: i^major7 vi^dim ii^m7 v^dim7 :|", chord_sleep: 0.4, scale: :aeolian
  zplay "%-1 vii %-0 iii vi %0 ii v %0 i iv", chord_sleep: 0.4
  zplay "G'e0 1 2 1' |: i^7 :2||: %-0 iv^dim :2|"
  zplay "G'e0 1 e^2 1 0 1' |: i^6 :2||: %-0 iv^dim7 :2|", key: :d3, scale: :mixolydian
  zplay "G'e8 7 6 5 3 2 1 0' %-0 ii^m7 v^add11 %1 i^maj9 %-1 vi^m9", key: :e2
  zplay "G'e(0,5)*2' i v vi"
  zplay "G'e(0..5)' i v vi"
end

def testinverseoffset
  # inverse and offset works only for zero based notation
  in_thread do
    zplay "|:q0 1 2 0:|:q 2 3 h4:|@:e4 5 4 3 q2 0:|:q0 _4 ^h0:@|", inverse: true, offset: -3
  end
  zplay "|:q0 1 2 0:|:q 2 3 h4:|@:e4 5 4 3 q2 0:|:q0 _4 ^h0:@|"
end

def testcontrolchars
  zplay "q S4 0 2 4"
  with_synth :beep do
    zplay "q R1 0123 R2 0123 R3 0123 R4 0123", groups: false
  end
end

def testrandom
  zplay "e(..0123)"
  sleep 0.5
  zplay "e(..0123)?"
  sleep 0.5
  zplay "e(..0123)?*1"
  sleep 0.5
  zplay "e(00000,10000)?2"
  sleep 0.5
  zplay "e(0..2)%s"
  sleep 0.5
  zplay "e(0..2)%r"
  sleep 0.5
  zplay "e(0..2)%m"
  sleep 0.5
  zplay "e(0..6)?"
  sleep 0.5
  zplay "e(0..6)?2"
  sleep 0.5
  zplay "e(0..6)?2*2"
  sleep 0.5
  zplay "e(0,6)*11"
  sleep 0.5
  zplay "e(1000,4000)^wqqee"
  sleep 0.5
  zplay "e(0..8)^wqqeee"
  sleep 0.5
  zplay "e(0..8)^wqqeee~"
  sleep 0.5
  zplay "e(11..1111)+111?^qe"
  sleep 0.5
  zplay "e(0..8)+1?2%r^eqe*3"
  sleep 0.5
  zplay "e Z1.? ? ? ? ? Z[1.15,0.5,1] ? ? ? ? Z1.(1,5) ? ? ? ?"
  sleep 0.5
  with_synth :beep do
    2.times do zplay "q ii 443e45 iv 01212345 i q 223e45 v [q6654,e64534231,q????]", chord_sleep: 0, groups: false end
    zplay "q $ I? C0.? (0,1) I? C0.? (1,2) I? C0.? (2,3) $ [0,1,2] I? [3,4,5] I? [3,4,5] ~ ????????? ", groups: false
  end
end

def testslide
  with_synth :chiplead do
    zplay "q |: ~ 80 ~ 50 :|", groups: false
    zplay "q ~0.5 0123", groups: false
    zplay "q ~1 0123 ", groups: false
    zplay "h2q212 ..q ~0.04 25 h4.2 ..q ~0.14 25 42 q ~0.14 2121111", groups: false
  end
end

def testzsample
  zplay "|:q0120:|:q23h4:|@:e4543q20:|:q0_4^h0:@|", sample: :ambi_drone, key: :c4, sustain: 0.25, groups: false
  zplay "|:q0120:|:q23h4:|@:e4543q20:|:q0_4^h0:@|", sample: :ambi_drone, key: "c2", sustain: 0.25, rate_based: true, groups: false
  zplay "h2q212 ..q ~1.15 25 h4 .2 ..q ~1.25 25 42 q ~1.25 2121111", sample: :ambi_piano, sustain: 0.25, key: "c", amp: 2, groups: false
  zplay "h2q212 q ~0.0 2555 h4.2 q ~0.14 2555 42 q ~0.1 2121111", sample: :ambi_piano, sustain: 0.25, key: "c", amp: 2, groups: false
  zplay "q004455h4q332211h0 *|: q443322h1 :|*", sample: :ambi_glass_rub, rate: 2.0, amp: 0.5, groups: false
end

def testsingledegrees
  (scale :gong).reflect.each do |k|
    [1,3,6].each do |d|
      zplay d, key: 40+k, scale: :blues_minor, sleep: 0.125
    end
  end
end

def testarraydegrees
  zplay [3,3,2,2,1,1,2,2,3,3,2,2,1,1,2,2], key: :c, scale: :chromatic, sleep: 0.125
  zplay (scale :gong).reflect.to_a,  key: 50, scale: :blues_minor, sleep: 0.125
  zplay [[0, 0.5], [0, 0.5], [0, 1], [1, 1]], scale: :aeolian
  zplay [0,2,4,5,6,7].zip(0.1.step(2.0,0.1).to_a), sleep: 0.125
end

def testzmidi
  zplay "|: q 53 53 53 57 h 60 q 53 53 ; h 55 q 60 60 h 57 q 53 53 ; q 55 55 57 55 w 53 :|",
    midi: true
end

def testlsystem
  with_synth :beep do
    zplay "q1", rules: {"0"=>"02","2"=>"5320"}, gen: 3, groups: false
    zplay "q?", rules: {"?"=>"q?e???q?"}, gen: 2, scale: :major_pentatonic, groups: false
    zplay "q1", rules: {/[0-6]/=>"(0..6)^qeqqe"}, gen: 2, scale: :gong, groups: false
    zplay "q1", rules: {/(3)1/=>"q'$1+1'1'$2+2'",/[1-7]/=>"e313"}, gen: 4, groups: false
    zplay "q123", rules: {/[1-9]/=>"'$*1' [e,q] '$*2'"}, gen: 4, groups: false
    zplay "q 1 1 1 ", rules: {/(?<= ([1-9]) ([1-9]) )/=>"0.6%=<?=(-3,3)>' $1+?' '$2+?' "}, gen: 4, groups: false
  end
end

def testSimult
  zplay "q 024 0 2 4 310 3 1 4 346 6 4 3 024"
  zplay "q |: q HB H BHS H :2| q BH B q SH H "*1,
  use: {
    B: :bd_tek,
    S: :drum_snare_soft,
    H: {sample: :drum_cymbal_closed, amp: 0.2}
  }
end

def testListSyntax
  zplay "w 5 ((5 3)(3 2 1 0)) 7 2"
  zplay "w 5 q5 3 e3 2 1 0 w 7 2"
  zplay "h 1 (0 2 1 3) 2 ((4 2)1 3 1) 5 (6 4(5 3)2) 3 (2 3 1 4) "
  zplay "w (0(1 2(2 3(5))))"
  zplay "h 1 (5 3) w 1 (3 1(2 1 0)) -2 (-1 2 (3 4(7 8))) ^3 _8"
end

def testUseChars
  zplay "q|: X O e X X q O :|", use: {"X": :bd_tek, "O": :drum_snare_soft}
  zplay "q|: X O e X X q O :|", use: {"X": {note: 40, port: "loopmidi", channel: 8}, "O": {note: 30, port: "loopmidi", channel: 8}}
  zplay "q|: O X X X X :|", use: {"X": :bd_tek, "O": {sample: :ambi_choir, rate: 0.2, sleep: 0}}
end

def testpreparse
  in_thread do # parse from c using Z escape char
    zplay "|:Z0.25 cdec:|:ef Z0.5 g:|@:Z0.125 gagf Z0.25 ec:|:c _g^ Z0.5 c:@|", parsekey: :c, key: :e, groups: false
  end
  zplay "|:(cdec):|:((ef)g):|@:((ga)(gf)ec):|:((c_g)^c):@|", parsekey: :c, key: :e, groups: false
end

def testeffects
  zplay "Z4 B", use: {"B": :misc_cineboom, run:[{with_fx: :flanger, decay: 1, depth: 8 }]}
  zplay "q 0 1 2 3 4 3 2 1", run: [{with_fx: :echo}]
  zplay "q 0 1 F 2 3 4 2 !3 1", use:{"F": {run:[{with_fx: :echo}]}}
end

def testadjust
  zplay "q 0 1 3 2 4 5 6 7 8 9", adjust: { pan: ->(){rrand_i(-1,1)} }
  zplay "q 0 1 2 3 4 5 6 7 8 9", adjust: { amp: (zrange :circ, 0, 1, 10).ring.mirror }
end


testzplay
testchords
testinverseoffset
testcontrolchars
testrandom
testslide
testzsample
testsingledegrees
testarraydegrees
testzmidi
testSimult
testListSyntax
testUseChars
testpreparse
testeffects
testadjust
testlsystem
