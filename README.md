![Ziffers](https://raw.githubusercontent.com/amiika/ziffers/master/logo.svg?sanitize=true)

# Ziffers: Numbered musical notation for Sonic Pi 
Ziffers is a numbered musical notation (aka. Ziffersystem) that makes composing melodies easier and faster for any key or scale. 

Writing and playing melodies will be as simple as:
```
zplay "q4e11q21034", key: "f", scale: "major"
```
or
```
zplay "|:44332233:|.4h4", key: :c, scale: :chromatic
```

Just copy the [source](https://raw.githubusercontent.com/amiika/ziffers/master/ziffers.rb) and run it in a free buffer or use **run_file** command to include the ziffers.rb file.

# Basic notation

Ziffers is a [numbered notation](https://en.wikipedia.org/wiki/Numbered_musical_notation) for music, meaning you write melodies using numbers that represent notes in some scale. Ziffers parses custom "ASCII" notation with **zparse** method and produces array of hash objects that contains parameters which can be played using **zplay** method. You can also use **zparams** method to use produced notes in any other method.

## Numbers 1-7 (and 8,9)

Notes are marked as numbers 1-7 representing the position in used scale. Default key is :c and scale :major making the numbers 1=C, 2=D, 3=E .. and so forth. 

## Note lengths

Default note length is quarter note, meaning 0.25 sleep after the note plays. Note length characters are sticky, so you only have to type note length when you need to change the following note lengths.

For example note lengths in Blue bird song can be encoded using characters **w** and **q** for Whole and Quarter notes:
```
zplay("5353 5653 4242 4542 5353 5653 w5 q5432 w1")
```

Now exactly same song using different escape notation:
```
zplay("5353 5653 4242 4542 5353 5653 Z1 5 Z0.25 5432 Z1 1")
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

## Octave change

To create higher notes you can use + which makes octave go up, for example +1 is gain C but one octave up. Numbers 8 and 9 is exactly same as +1 and +2. Use - to change the octave one step lower.

Octave change is sticky, meaning it affects all of the notes that comes after the +/- character

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

Use **?** for random note

## Random between

Use (1,5) for random numer between 1 and 5. (1,7) is same as ?.

## Choose random from array

Use [q1,e2345,h3] for randomly selected lengths and degree/degrees from the array.

# Chords

Chords can be used within the notation using roman numerals: i ii iii iv v vi vii or by custom chord syntax {1,3,5}

Chords can be customized with ^ like: vi^dim. See Sonic Pi:s chord_names list for supported chord names.

Chords can also be inverted using % char, for example %1 to invert all following chords up by one.

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
  "|:q1e11q12|q3113;q2-77+2|q31h1;q.5e4q32|q31h1:|"\
  "|:q5e55q43|q2-77+2;q4e44q32|q3113;q4e44q32|q31h1:|"

n = zparse(ievanpolka,{key:"C", scale:"minor"})
notes = zparams(n, :note)
pitch = zparams(n, :pitch)
notes = [notes,pitch].transpose.map {|x| x.reduce(:+)}
durations = zparams(n, :sleep)

play_pattern_timed notes, durations
```
