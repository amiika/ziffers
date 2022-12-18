<img src="https://github.com/amiika/ziffers/raw/ziffers2/ziffers.png" width=250, border=0, padding=0>

# Ziffers: Numeric notation for composing algorithmic and generative music using Sonic Pi
Ziffers is a generative numbered musical notation (aka. Ziffersystem) and a live code golfing framework that makes composing melodies and rhythms easier and faster in [Sonic Pi](https://sonic-pi.net/).

Writing and playing melodies in any key or scale will be as simple as:
```
zplay "q 4 e 1 1 q 2 1 r #3 4 ", key: "f", scale: "major", synth: :piano
```
or playing loops:
```
zloop :ride, "e 3 3 2 2 1 1 2 2", key: :c, scale: :chromatic, synth: :piano
```
or loops with generative live rules:
```
z1 "e1",
rules: {
  "1"=>"3",
  "3"=>"2",
  "2"=>"4",
  "4"=>"(1,6)",
  "5"=>"1",
  "6"=>"2"
}, synth: :pretty_bell
```
or complex drumlines with custom sample or midi mapping:
```
breakbeat = "| HB H | HS (H B)   | (HB S) (HB S)   | HS (H B S)  |
             | HB H | HS (H B S) | (H H) (S r B)   | HS (H H)    |"

samples = {
  B: :bd_tek,
  S: :drum_snare_soft,
  H: {sample: :drum_cymbal_closed, amp: 0.2}
}

z1 breakbeat, use: samples, duration: 0.25
```
or play infinite sequences. Easy as:
```
zplay pi, rhythm: "q q h q q h h q ee h q ee"
```
or simple [aleatoric](https://en.wikipedia.org/wiki/Aleatoric_music) melodies:
```
z1 "[0,3,5] 4 (1,3) (4,6) 2 e <3 0 (2,4)> (5,7)", scale: :ahirbhairav, key: :e, synth: :piano, attack: 0.25
```
or go crazy and create lists and do list operations using transformations and nested notation:
```
z1 "q (0 1 (3,7) 3)~<*>(4 [6,4,[5,4,2,7]] (0,(5,8)) (1,6))", synth: :kalimba
```
and much more ... See [Ziffers wiki](https://github.com/amiika/ziffers/wiki) or download [A4 cheatsheet](https://github.com/amiika/ziffers/raw/master/Cheatsheet.pdf) to learn more.

Here is a cheatsheet you can copy to Sonic Pi editor:
```
# Pitches: -2 -1 0 1 2
# Chords: 0 024 2 246
# Note lengths: w 0 h 1 q 2 e 3 s 4
# Subdivision: [1 2 [3 4]]
# Decimal durations: 0.25 0 1 [0.333]2 3
# Octaves: ^ 0 ^ 1 _ 2 _ 3
# Escaped octave: <2> 1 <1>1<-2>3
# Roman chords: i ii iii+4 iv+5 v+8 vi+10 vii+20
# Named chords: i^7 i^min i^dim i^maj7
# Modal interchange (a-g): iiia ig ivf^7
# Escape/eval: {10 11} {1.2 2.43} {3+1*2}
# Randoms: % ? % ? % ?
# Random between: (-3,6)
# Random selections: [q 1 2, q 3 e 4 6]
# Repeat: [: 1 (2,6) 3 :4]
# Repeat cycles: [: <q e> (1,4)  <(2 3) (3 (1,7))> :]
# Lists: h 1 q(0 1 2 3) 2
# List cycles: (: <q e> (1,4) <(2 3) (3 (1,7))> :)
# Loop cycles (for zloop or z0-z9): <0 <1 <2 <3 <4 5>>>>>
# Basic operations: (1 2 (3 4)+2)*2 ((1 2 3)+(0 9 13))-2 ((3 4 {10})*(2 9 3))%7
# Product operations: (0 1 2 3)+(1 4 2 3) (0 1 2)-(0 2 1)+2
# Euclid cycles: (q1)<6,7>(q4 (e3 e4) q2) or (q1)<6,7<(q4 q3 q2)
# Transformations: (0 1 2)<r> (0 1 2)<i>(-2 1) etc.
# List assignation: A=(0 (1,6) 3) B=(3 ? 2) B A B B A
# Random repeat: (: 1 (2,6) 3 :4)
# Conditionals: 1 {%<0.5?3} 3 4 (: 1 2 {%<0.2?3:2} :3)
# Functions: (0 1 2 3){x%3==0?x-2:x+2}
# Polynomials: (-10..10){(x**3)*(x+1)%12}
```

# Quick start

## Requirements

- [Sonic Pi](https://sonic-pi.net/)
- Clone using git or download [latest release](https://github.com/amiika/ziffers/releases/latest)

## Install ziffers

Install Ziffers to your Sonic Pi by cloning this project into your home directory (this makes referencing easier as most of the examples use ~ shorthand to require stuff). Ziffers can then be required to your Sonic Pi project using:

```
require "~/ziffers/ziffers.rb" # ~ references ziffers under users home folder, works also in Windows
```

Stay up to date as the Ziffers is an ongoing project. Post Issues to report bugs or to ask questions.

## Examples

There are some pretty random examples in the [Examples](https://github.com/amiika/ziffers/tree/master/examples)-folder. You can also try out [one line](https://github.com/amiika/ziffers/blob/master/test/play_tests.rb) examples from tests or browse trough [wiki](https://github.com/amiika/ziffers/wiki). If you make some nice tunes do a pull request to Examples folder to share! Thanks!

## Documentation

Syntax and methods are documented in [Ziffers wiki](https://github.com/amiika/ziffers/wiki).

# Help & Contributions

For bugs post an [issue](https://github.com/amiika/ziffers/issues) or a fix using merge request. Use [discussions](https://github.com/amiika/ziffers/discussions) for general questions and feature requests.
