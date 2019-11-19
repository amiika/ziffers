![Ziffers](https://raw.githubusercontent.com/amiika/ziffers/master/logo.svg?sanitize=true)

# Ziffers: Numbered musical notation for composing algorithmic and generative music using Sonic Pi
Ziffers is a numbered musical notation (aka. Ziffersystem) that makes composing melodies and rhythms easier and faster in [Sonic Pi](https://sonic-pi.net/).

Writing and playing melodies in any key or scale will be as simple as:
```
zplay "q 4 e 1 1 q 2 1 0 3 4", key: "f", scale: "major"
```
or playing loops:
```
zloop :ride, "q2 e4 3 3 3 2 3 4 3 3 3 3 3 2 3", key: :c, scale: :chromatic
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
and much more ...

# Quick start

## Requirements

Install [Sonic Pi](https://sonic-pi.net/)

## Install ziffers

Install Ziffers to your Sonic Pi by cloning this project into your home directory (this makes referencing easier as most of the examples use ~ shorthand to require stuff). Ziffers can then be required to your Sonic Pi project using:

```
require "~/ziffers/ziffers.rb" # ~ references ziffers under users home folder, works also in Windows
```

Stay up to date as the Ziffers is an ongoing project. Post Issues to report bugs or to ask questions.

## Examples

Try out [one line](https://github.com/amiika/ziffers/blob/master/play_tests.rb) examples and more [complex examples](https://github.com/amiika/ziffers/tree/master/examples).

# Documentation

Syntax and methods are documented in [Ziffers wiki](https://github.com/amiika/ziffers/wiki).

# Help

Post [issue](https://github.com/amiika/ziffers/issues) or ask help from [chat](https://chat.toplap.org/channel/ziffers).
