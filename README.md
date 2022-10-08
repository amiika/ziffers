<img src="https://github.com/amiika/ziffers/raw/ziffers2/ziffers.png" width=250, border=0, padding=0>

# Ziffers: Numbered musical notation for composing algorithmic and generative music using Sonic Pi
Ziffers is a numbered musical notation (aka. Ziffersystem) and live code golfing language that makes composing melodies and rhythms easier and faster in [Sonic Pi](https://sonic-pi.net/).

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

z1 breakbeat, use: samples, sleep: 0.25
```
or play infinite sequences. Easy as:
```
zplay pi, rhythm: "q q h q q h h q ee h q ee"
```
or create lists and do list operations using randomization and crazy recursive notation:
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
# Cycles: [: <q,e> 1  <2 3,3 5> :]
# Lists: h 1 q(0 1 2 3) 2
# List operations: (1 2 (3 4)+2)*2 ((1 2 3)+(0 9 13))-2 ((3 4 {10})*(2 9 3))%7
# List assignation: A=(0 (1,6) 3) B=(3 ? 2) B A B B A
# Random repeat: (: 1 (2,6) 3 :4)
# Conditionals: 1 {%<0.5?3} 3 4 (: 1 2 {%<0.2?3:2} :3)
# Functions: (0 1 2 3){x%3==0?x-2:x+2}
# Polynomials: (-10..10){(x**3)*(x+1)%12}
```

# Quick start

## Requirements

- [Sonic Pi](https://sonic-pi.net/)
- Git (if you haven't used git before see [full instructions](https://github.com/amiika/ziffers/wiki/Install))

## Install ziffers

Install Ziffers to your Sonic Pi by cloning this project into your home directory (this makes referencing easier as most of the examples use ~ shorthand to require stuff). Ziffers can then be required to your Sonic Pi project using:

```
require "~/ziffers/ziffers.rb" # ~ references ziffers under users home folder, works also in Windows
```

Stay up to date as the Ziffers is an ongoing project. Post Issues to report bugs or to ask questions.

## Examples

Try out [one line](https://github.com/amiika/ziffers/blob/master/test/play_tests.rb) examples or browse trough [wiki](https://github.com/amiika/ziffers/wiki). More examples coming soon (ish), as old examples are not yet updated for Ziffers 2.

## Documentation

Syntax and methods are documented in [Ziffers wiki](https://github.com/amiika/ziffers/wiki).

# Help & Contributions

Post [issue](https://github.com/amiika/ziffers/issues) or fixes using merge request.
