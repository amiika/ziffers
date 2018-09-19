![Ziffers](https://raw.githubusercontent.com/amiika/ziffers/master/ziffers.svgs?sanitize=1)
# Ziffers: Numbered musical notation for Sonic Pi 
Ziffers is a numbered musical notation (aka. Ziffersystem) that makes composing melodies easier and faster for any key or scale. 

Writing and playing melodies will be as simple as:
```
zplay("4q11h21034",{key:"f",scale:"major"})
```
or
```
zloop("44332233",{key:"c", scale:"chromatic", sleep:0.25})
```

Just copy the [source](https://raw.githubusercontent.com/amiika/ziffers/master/ziffers.rb) and run it in a free buffer or use **run_file** command to include the ziffers.rb file. Check out the method usage from [Ziffers methods](#ziffers-methods)

# Basic notation

Ziffers is a [numbered notation](https://en.wikipedia.org/wiki/Numbered_musical_notation) for music, meaning you write melodies using numbers that represent notes in some scale. Ziffers parses custom "ASCII" notation with **zparse** method and produces nested array that can be played or looped with the Sonic Pi.

## Numbers 1-7 (and 8,9)

Notes are marked as numbers 1-7 representing the position in used scale. Default key is :c and scale :major making the numbers 1=C, 2=D, 3=E .. and so forth. 

## Octave change

To create higher notes you can use + which makes octave go up, for example +1 is gain C but one octave up. Numbers 8 and 9 is exactly same as +1 and +2. Use - to change the octave one step lower.

Octave change is sticky, meaning it affects all of the notes that comes after the +/- character

## Rest or silence

Use 0 to create silence in melodies

## Sharp and flat

- **\&** is flat
- **\#** is sharp

Sharps and flats are not sticky so you have to use it every time before the note number. For example in key of C: #1 = C#

## Note lengths

Default note length is Half note, meaning 0.5 sleep after the note plays. Note length characters are sticky, so you only have to type note length when you need to change the following note lengths.

For example Blue bird song using default Half notes then some characters **w** and **q** for Whole and Quarter notes:
```
zplay("5353 5653 4242 4542 5353 5653 w5 q5432 w1")
```

Now exactly same song using different escape notation:
```
zplay("5353 5653 4242 4542 5353 5653 '1' 5 '0.25' 5432 '1' 1")
```

### Standard note lengths

- **m** = Max = 8/1 = 8 beats
- **l** = Long = 4/1 = 4 beats
- **d** = Double whole = 2/1 = 2 beats
- **w** = Whole = 1/1 = 1 beat
- **h** = Half = 1/2 = 0.5 beat
- **q** = Quarter = 1/4 = 0.25 beat
- **e** = Eighth = 1/8 = 0.125 beat
- **s** = Sixteenth = 1/16 = 0.0625 beat
- **t** = Thirty-second = 1/32 = 0.03125 beat
- **f** = Sixty-fourth = 1/64 = 0.015625 beat

### Dotted notes

**.** for dotted notes. First dot increases the duration of the basic note by half of its original value. Second dot half of the half, third dot half of the half of the half ... and so on. For example dots added to Whole note "w." will change the duration to 1.5, second dot "w.." to 1.75, third dot to 1.875.

### Custom lengths

You can also use longer escaped notation, for example: "Z1.123 1"

Default note length can also be changed via parameter, for example:
```
# Plays short efg notes for 1 note per beat.
zplay("123",{release:0.5, sleep: 1})
```

## Bars

**|** Bars are just nice

## Repeats

### : Basic repeat

Use **:** as basic repeat, for example in Frere Jacques:

```
# Repeat every bar
zplay("|: 1231 :|: 34w5 :|: q5654h31 :|: 1-5+w1 :|")
```

### Alternative sections or numbered endings

Use **;** in repeats for alternative sections, like "|: 123 ; 432 ; 543 :|". 

Alternative endings in ievan polkka:

```
zplay("|:q1e11q12| q3113 |;q2-77+2 |q31h1;q.5e4q32|q31h1:|"\
      "|:q5e55q43|q2-77+2|;q4e44q32|q3113;q4e44q32|q31h1:|", :g, :minor)
```

### D.S repeat

Use **@ ... @** to repeat multiple sections. For example this play row row row your boat 2 times and then the last section 2 times at the end:

```
zplay("|:.1.1|1q2h.3|3q2h3q4|w.5|@q888555333111|5q4h3q2|w.1:@|")
```

### Jump repeat, D.C:ish

Use **\*** to start from beginning and continue until first **\***. If & is at the end it works like D.C, otherwise the song will continue after the & character. For example:

```
zplay("| 7162 *| 6354 |*")
```

## Volume and panning 

### < Volume up and down >

**<** Volume up
**>** Volume down

Default volume or amp is 1. Volume characters changes the amp 0.25 by default. You can also change the amp treshold, for example:

```
#Changes amp treshold to 0.5, meaning first note is played at amp 1.5, second 2, and last 1.5
zplay("<1<2>1",:d,:minor,0.5,0.5)
```

### Pan

Use P1, P1 or P-1

Use **%** to change the octave randomly

# Slide

**~** starts and ends the slide. Remeber to add slide speed or/and space after the first slide marker.

For example:
```
# Start slide with 0.4 speed, set release to 3, set sleep between slide notes to 0.4. 
zplay("~0.4 R3 Z0.4 12321~")
```

Go crazy with the slide. This example uses slide to create bass sounds:

```
use_synth :blade

live_loop :boom do
  zplay("Z0.25 ~0.2 1 T-71 7")
end

live_loop :melody do
  zplay("q? P-1 ?? P1 ?>? P-1 ?~??<?~?~? P1 ??>?~?~? P-1 ?<?~?",{key:"c",scale:"minor_pentatonic"})
end

live_loop :bass do
  zplay("--q223222",{key:"c",scale:"minor"})
end
```

Just remember to end the slide in long melodies, otherwise it will be slide all the way.

# Randomization

With randomization you can create random or semirandom melodies, for example:

```
#notes = " |: ???0???q(1,2)[6,7](1,2)[6,7]%(1,2)[6,7](1,2)[6,7] :| "
```

## Random note

Use **?** for random note

## Random between

Use (1,5) for random numer between 1 and 5. (1,7) is same as ?.

## Choose random from array

Use [1,2,3] for randomly selected number from the array

# Ziffers methods

## zparse

The heart of ziffers. Parses string and returns nested array.

For example:
```
print zparse("|: 1231 :|: 34w5 :|: q5654h31 :|: 1-5+w1 :|")
```
Prints:
```
...
```

### Params

zparse(n, opts)

* n = ascii notation as presented in the first section

## zplay

Plays the ziffers. Plays the result array from **zparse** or parses the string directly. Always use preparsed melody if you are using **zplay** inside **live_loop**! 

Actual method (Useful if you want to implement your own play method):
```
... tbd
```

## zloop

Loops the ziffers. Uses result from **zparse** or parses the string.

Actual method (Useful if you want to implement your own loop method):
```
... tbd
```

## zparams

Helper to get any separate array from nested array, for example slide information:
```
n = zparse("~1~2")
print zindex(n,:slide)
# Prints [true,false]
```

# Using ziffers with Sonic Pi methods

Ziffers is meant to provide easy way to write and experiment with melodies. By **zparams** you can easily use ziffers with other Sonic Pi methods such as **play_pattern_timed**

Example of using Ziffers with default Sonic Pi methods:
```
ievanpolka = \
  "|:q1e11q12|q3113;q2-77+2|q31h1;q.5e4q32|q31h1:|"\
  "|:q5e55q43|q2-77+2;q4e44q32|q3113;q4e44q32|q31h1:|"

n = zparse(ievanpolka,{key:"C", scale:"minor"})

notes = zparams(n, :note)
durations = zparams(n, :sleep)

play_pattern_timed notes, durations
```
