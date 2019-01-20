![Ziffers](https://raw.githubusercontent.com/amiika/ziffers/master/logo.svg?sanitize=true)

# Ziffers: Numbered musical notation for composing algorithmic and generative music using Sonic Pi
Ziffers is a numbered musical notation (aka. Ziffersystem) that makes composing generative melodies easier and faster for any key or scale. 

Writing and playing melodies will be as simple as:
```
zplay "q4e11q21034", key: "f", scale: "major"
```
or
```
zplay "|:44332233:|.4h4", key: :c, scale: :chromatic
```

Just copy the [source](https://raw.githubusercontent.com/amiika/ziffers/master/ziffers.rb) and run it in a free buffer or use **run_file** command to include the ziffers.rb file. Some features like **lsystem** or **zpreparse** also requires [ziffer utils](https://raw.githubusercontent.com/amiika/ziffers/master/ziffers_utils.rb) to run.

# Basic notation

Ziffers is a [numbered notation](https://en.wikipedia.org/wiki/Numbered_musical_notation) for music, meaning you write melodies using numbers that represent notes in some scale. Ziffers parses custom "ASCII" notation with **zparse** method and produces array of hash objects that contains parameters which can be played using **zplay** method. You can also use **zparams** method to use produced notes in any other method.

## Numbers 1-9

Notes are marked as numbers 1-9 representing the position in used scale. Default key is :c and scale :major making the numbers 1=C, 2=D, 3=E .. and so forth. If some scale does not have certain degree, for example 8 in major scale, it is transposed automatically meaning 8 is 1 in higher octave. 

## Octave change

To create higher notes you can use ^ which makes octave go up, for example ^1 is gain C but one octave up. Numbers 8 and 9 in major scale are exactly same as ^1 and ^2. Use _ to change the octave one step lower.

Octave change is sticky, meaning it affects all of the notes that comes after the ^/_ character

## Negative degrees

Using negative degrees is other way to play lower notes. Consider scale as number line from negative to positive, for example: -987654321+123456789. In most cases it is more intuitive to use -2 than _6. You can also use lower numbers using eval syntax, for example: =-12

## Note lengths

Default note length is quarter note, meaning 0.25 sleep after the note plays. Note length characters are sticky, so you only have to type note length when you need to change the following note lengths.

For example note lengths in Blue bird song can be defined using characters **w** and **q** for Whole and Quarter notes:
```
zplay("5353 5653 4242 4542 5353 5653 w5 q5432 w1")
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


### Alternative ways to define note lengths

Same note lengths can also be defined using different escape notations:

**Decimals:**
```
zplay("5353 5653 4242 4542 5353 5653 Z1 5 Z0.25 5432 Z1 1")
```

**Fractions**
```
zplay("1/4 5353 5653 4242 4542 5353 5653 4/4 5 1/4 5432 4/4 1")
```

**Note that only 1/1*n works. No support fractions where numerator is bigger than 9, eg. 12/64** 

Default note length can also be changed via parameter, for example:
```
# Plays short efg notes for 1 note per beat.
zplay("123",{release:0.5, sleep: 1})
```

### Dotted notes

**.** for dotted notes. First dot increases the duration of the basic note by half of its original value. Second dot half of the half, third dot half of the half of the half ... and so on. For example dots added to Whole note "w." will change the duration to 1.5, second dot "w.." to 1.75, third dot to 1.875.


### Parse degrees from note names

You can also use notation based on note names to parse melody the ziffers notation. In order to use note names you have to use Z or fractions to define note lengths.

Include [ziffer utils](https://raw.githubusercontent.com/amiika/ziffers/master/ziffers_utils.rb) to use **zpreparse**-function to parse note names to degrees:
```
print zpreparse "1/4 cdefg - abg", :e
# Prints "1/4 67123 - 453"
```

Use zplay with note names by defining the **parsekey**. Ziffers utils must be included. These two play exactly same melody:
```
zplay("|:1/4 1231:|:34 2/4 5:|@:1/8 5654 1/4 31:|:1 -5+ 2/4 1:@|", key: :e) 
zplay("|:1/4 cdec:|:ef 2/4 g:|@:1/8 gagf 1/4 ec:|:c -g+ 2/4 c:@|", parsekey: :c, key: :e)
```

## Rest or silence

Use 0 to create silence in melodies. 0 can be combined with note length, meaning it will sleep the length of the 0 note.

## Sharp and flat

- **\&** is flat
- **\#** is sharp

Sharps and flats are not sticky so you have to use it every time before the note number. For example in key of C: #1 = C#

## Bars

**|** Bars are just nice

## Repeats

### : Basic repeat

Use **:** as basic repeat, for example in Frere Jacques:

```
# Repeat every bar
zplay("|: 1231 :|: 34w5 :|: q5654h31 :|: 1_5^w1 :|")
```

### Alternative sections or numbered endings

Use **;** in repeats for alternative sections, like "|: 123 ; 432 ; 543 :|". 

Alternative endings in ievan polkka:

```
zplay("|:q1e11q12| q3113 |;q2_77^2 |q31h1;q.5e4q32|q31h1:|"\
      "|:q5e55q43|q2_77^2|;q4e44q32|q3113;q4e44q32|q31h1:|", :g, :minor)
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

## Volume 

### < Volume up and down >

**<** Volume up
**>** Volume down

Default volume or amp is 1. Volume characters changes the amp 0.25 by default. You can also change the amp treshold, for example:

```
#Changes amp treshold to 0.5, meaning first note is played at amp 1.5, second 2, and last 1.5
zplay("<1<2>1",:d,:minor,0.5,0.5)
```

# Control characters

Capitalized letters are used as control characters, to change properties of following degrees/notes.

List of control characters:

- **A** = :amp 
- **E** = :env_curve 
- **C** = :attack
- **P** = :pan
- **D** = :decay
- **S** = :sustain
- **R** = :release 
- **Z** = :sleep 
- **X** = :chordSleep
- **T** = :pitch
- **K** = :key 

## Pan

Use P1, P1 or P-1

# Slide

**~** starts and ends the slide. Remeber to add slide speed or/and space after the first slide marker.

For example:
```
zplay "~ 123456789"
# Note slide set to 0.4 
zplay("~0.4 12321 ")
```

(TODO: release and sleep not working after the note_slide)

# Randomization

With randomization you can create random or semirandom melodies, for example:

```
zplay " |: ???0???q(1,2)[6,7](1,2)[6,7] (1,2)[6,7](1,2)[6,7] :| "
```

## Random note

Use **?** for random degree between 1-7

## Random between

Use (1,5) for random numer between 1 and 5. (1,7) is same as ?.

(1,4,3) = create 4 random numbers between 1 and 4: "2341"
(3000,4000,4;qeee) = create 4 random numbers between 3000 and 4000: "q3e532"

## Random sequence

(1..7) = create random sequence: "1324657". 
(1..7,3) = pick 3 from random sequence: "152"
(1..3;qe) = create sequence with note lengths: "q2e23"

## Choose random from array

Use [q1,e2345,h3] for randomly selected lengths and degree/degrees from the array.

It is also possible to combine other random syntax: [(1,3),(1..5,2)]

# Chords

Chords can be used within the notation using roman numerals: i ii iii iv v vi vii or by custom chord syntax {1,3,5}

Chords can be customized with ^ like: vi^dim. See Sonic Pi:s chord_names list for supported chord names.

Chords can also be inverted using % char, for example %1 to invert all following chords up by one.

## Arpeggios

You can also create melodies by playing chord arpeggios using G character and chords. You can use subset of ziffers notation to denote chord notes and note lengths.

Examples:

```
zplay "G1231 i ii iii iv v vi vii"
zplay "Gq12e^3212 |: i^7 :3||: %-1 iv^dim7 :3|", key: :d4, scale: :mixolydian

```

# Ziffers methods

## zplay

Plays degrees in some key and scale. Function plays the hash array from **zparse** or parses the string or array first. You should consider using preparsed melody if you are using **zplay** inside **live_loop**.

You can use zplay with strings, integers and arrays, for example:

```
zplay 1 # Plays in :c :major
zplay [1,2,3], key: "f", sleep: 0.25
zplay "w1h2q3"
zplay [[1,1],[2,0.5],[3,0.25]] # Is same as w1h2q3
```

Run [examples](https://raw.githubusercontent.com/amiika/ziffers/master/play_tests.rb) in buffer to see various ways to use zplay.

## zmidi

Plays midi notes using space separated midi notation

```
zmidi "|: q 53 53 53 57 h 60 q 53 53 ; h 55 q 60 60 h 57 q 53 53 ; q 55 55 57 55 w 53 :|"
```

### Using samples

You can also use zplay with samples to create new "synths", for example:

```
zplay("554e56 12323456 q 334e56 e75645343", {sample: :guit_e_fifths, start: 0.2, finish: 0.25, amp: 3})
```

## zparse

The heart of ziffers. Parses string and returns hashmap that contains parameters to play single note

For example:
```
print zparse "1,2", key: :d
```
Prints:
```
[{:key=>:d, :scale=>:major, :release=>0.5, :sleep=>0.25, :pitch=>0.0, :amp=>1, :pan=>0, :amp_step=>0.5, :note_slide=>0.5, :control=>nil, :skip=>false, :pitch_slide=>0.25, :degree=>1, :note=>62}, {:key=>:d, :scale=>:major, :release=>0.5, :sleep=>0.25, :pitch=>0.0, :amp=>1, :pan=>0, :amp_step=>0.5, :note_slide=>0.5, :control=>nil, :skip=>false, :pitch_slide=>0.25, :degree=>2, :note=>64}]
 
```

## zarray

Parses integer degree arrays to hash arrays

```
print zarray [1,2]
# [{:key=>:c, :scale=>:major, :release=>1.0, :sleep=>0.25, :pitch=>0.0, :amp=>1, :pan=>0, :amp_step=>0.5, :note_slide=>0.5, :control=>nil, :skip=>false, :pitch_slide=>0.25, :note=>60}, {:key=>:c, :scale=>:major, :release=>1.0, :sleep=>0.25, :pitch=>0.0, :amp=>1, :pan=>0, :amp_step=>0.5, :note_slide=>0.5, :control=>nil, :skip=>false, :pitch_slide=>0.25, :note=>62}]
```

### Params

zparse(n, opts)

* n = ascii notation as presented in the first section


## zparams

Helper that creates array from hash, for example:

```
n = zparse("1,2")
print zparams(n,:note)
# Prints [60,62]
```

# Using ziffers with Sonic Pi methods

Ziffers is meant to provide easy way to write and experiment with melodies. By **zparams** you can easily use ziffers with other Sonic Pi methods such as **play_pattern_timed**. When using standard methods, remember to combine pitch to notes by transposing the arrays.

Example of using Ziffers with default Sonic Pi methods:
```
ievanpolka = \
  "|:q1e11q12|q3113;q2_77^2|q31h1;q.5e4q32|q31h1:|"\
  "|:q5e55q43|q2_77^2;q4e44q32|q3113;q4e44q32|q31h1:|"

n = zparse(ievanpolka,{key:"C", scale:"minor"})
notes = zparams(n, :note)
pitch = zparams(n, :pitch)
notes = [notes,pitch].transpose.map {|x| x.reduce(:+)}
durations = zparams(n, :sleep)

play_pattern_timed notes, durations
```

Look under examples to see other ways to use zparse and other Sonic Pi projects, such as Markov chains.

# Fractal melodies

Ziffers can be used to generate fractal melodies using L-system based approach. Include [ziffer utils](https://raw.githubusercontent.com/amiika/ziffers/master/ziffers_utils.rb) to use rules. Use **rules** to define hash-object specifying the transformation rules and **gen** to define amount of generations the rules are run against.

For example:
```
    zplay "1", rules: {"1"=>"13","3"=>"6431"}, gen: 3
```

Matched value is defined as string or regular expression. You can feed back the matched number with $ or ${1-9}. Use single quotes to run evaluation against the matched number:

```
	zplay "1", rules: {/(3)1/=>"q'$1+1'1'$2+2'",/[1-7]/=>"e313"}, gen: 4
	sleep 2
    zplay "123", rules: {/[1-9]/=>"'$*1' [e,q] '$*2'"}, gen: 4
```

## Stochastic melodies

Use 0.4%= syntax to define chance of replacement. This way you can vary the replaced matches when using alternative random seeds.

This example has 20% chance to tranform any number between 1 and 7 to six numbers randomly chosen from numbers between 1 and 9.
```
zplay "1234", rules: {/[1-7]/=>"0.2%=(1..9,6)"}, gen: 4
```

## Context dependent rules

Use regular expression lookbehind and lookahead syntax. For example this would match 3 only if it is between 1 and 2: /(?<=1)3(?=2)/

## Automata rules

Other way to use the L-system is to write rules that change the input in a way that the end result does not grow. This way you can predictable or unpredictable loops that are somewhat similar to Conways automata or "The game of life".

Example of using **lsystem** directly to produce a random loop from the different generations:
```
use_synth :chipbass

n = lsystem("12e3456",{"1"=>"[2,4]","2"=>"[1,5]","3"=>"5","4"=>"3","5"=>"[1,3]"},10).ring

live_loop :p do
  sample :bd_tek
  zplay n.tick
end
```