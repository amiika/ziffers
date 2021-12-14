<img src="https://github.com/amiika/ziffers/raw/ziffers2/ziffers.png" width=300 border=0, padding=0>

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
z1 "e1", rules: {
  "1"=>"3",
  "3"=>"2",
  "2"=>"4",
  "4"=>"(1,6)",
  "5"=>"1",
  "6"=>"2"
}
```
or complex drumlines with custom sample or midi mapping:
```
breakbeat = "| q HB H | HS (H B) | (H B) (H B) | HS (H B)  |
             |   HB H | HS H     | (H H) (r B) | HS (H H)  |"

samples = {
  B: :bd_tek,
  S: :drum_snare_soft,
  H: {sample: :drum_cymbal_closed, amp: 0.2}
}

z1 breakbeat, use: samples
```
or play infinite sequences. Easy as:
```
zplay pi, rhythm: "q q h q q h h q ee h q ee"
```
or create sets and do set operations using randomization and crazy recursive notation:
```
z1 "q {0 1 (3,7) 3}~<*>{4 [6,4,[5,4,2,7]] (0,(5,8)) (1,6)}", synth: :kalimba
```
and much more ...

See [Ziffers wiki](https://github.com/amiika/ziffers/wiki) for how to make your own.

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

Try out [one line](https://github.com/amiika/ziffers/blob/master/test/play_tests.rb) examples. More tests coming soon (ish), as old examples are not yet updated for Ziffers 2.

## Documentation

Syntax and methods are documented in [Ziffers wiki](https://github.com/amiika/ziffers/wiki).

# Help & Contributions

Post [issue](https://github.com/amiika/ziffers/issues) or fixes using merge request.
