![Ziffers](https://raw.githubusercontent.com/amiika/ziffers/master/logo.svg?sanitize=true)

# Ziffers: Numbered musical notation for composing algorithmic and generative music using Sonic Pi
Ziffers is a numbered musical notation (aka. Ziffersystem) that makes composing melodies easier and faster in [Sonic Pi](https://sonic-pi.net/).

Writing and playing melodies in any key or scale will be as simple as:
```
zplay "q 4 e 11 q 21034", key: "f", scale: "major"
```
or playing loops
```
zloop :ride, "q2 e43 33 23 43 33 33 23", key: :c, scale: :chromatic
```

# How to install

Install Ziffers to your Sonic Pi by cloning this project into your home directory (this makes referencing easier as most of the examples use ~ shorthand to require stuff). Ziffers can then be required to your Sonic Pi project using:
```
require "~/ziffers/ziffers.rb" # ~ references ziffers under users home folder, works also in Windows
```

Stay up to date as the Ziffers is an ongoing project. Aim is to keep Ziffers syntax stable but some parts are still looking for its place. Participate or post Issues if you have suggestions or questions about the project.

# Basic notation

Ziffers is a [numbered notation](https://en.wikipedia.org/wiki/Numbered_musical_notation) for music, meaning you write melodies using numbers that represent notes in some scale. Ziffers parses custom "ASCII" notation with **zparse** method and produces array of hash objects that contains parameters which can be played using **zplay** method. You can also use **zparams** method to use produced notes in any other method.

## Degree numbers 1-9

Notes are marked as numbers 1-9 representing the degrees or positions in the used scale. Default key is :c and scale :major making the numbers 1=C, 2=D, 3=E .. and so forth. If some scale does not have certain degree, for example 8 in major scale, it is transposed automatically meaning 8 is 1 in higher octave.

Ziffers is a single character language, which means that every single digit represents degree that is (by default) played sequentially. Digits that are grouped together can also be played simultaniously using **group** parameter.

Examples:
```
zplay "1234" # Plays 1234 sequentially
zplay "123 4", groups: true # Plays 123 as chord then 4
```  

Degrees higher than 9 for example in chromatic scale can be played using **Zero based notation** or by **Escaping degrees**.

## Zero-based notation 0-9 and T=10 & E=11

Degree based notation can also be changed to musical set-theory influenced [zero-based integer notation](https://en.wikipedia.org/wiki/Pitch_class#Integer_notation). Zero-based notation is especially useful with random sequences & string replacing lsystem-rules that may produce 0-values trough different mathematical operations.

Zero-based notation can be switched on by calling setZeroBased in Ziffers module:
```
Ziffers.setZeroBased true
zplay "(100..200)~"
zplay "0123456789TE", scale: :chromatic
```

## Octave change

To create higher notes you can use ^ which makes the note go one octave go higher, for example ^1 is same as 8 in major scale.

Use _ to change the octave one step lower.

Octave change is sticky, meaning it affects all of the notes that comes after the ^/_ character

## Negative degrees

Using negative degrees is other way to play lower notes. Consider scale as number line from negative to positive, for example: -9-8-7-6-5-4-3-2-1 123456789. In most cases it is more intuitive to use - 2 than _ 6. You can also use lower numbers using **=** syntax, for example: =-12

Negative degrees are not sticky! It makes generation of sequences and rules easier.

## Escaping degrees using =

In some cases it might be easier to escape the digits that require more characters than one. To do this you can use the **=** character.

**=** character evaluates the characters between the **=** and the next empty space:

```
zplay "=-10 =12 =24"
zplay "=1*1 =2*2 =3*3 =4*4"
```

You can also use [ruby string interpolation](https://en.wikibooks.org/wiki/Ruby_Programming/Syntax/Literals#Interpolation) in combination with the **=** character:

```
# Plays degrees [0, 0, 2, 3, 4, 6, 6, 9, 8, 12, 10, 15, 12, 18, 14, 21, 16, 24, 18, 27]
10.times do |n|
  zplay "=#{n*2} =#{n*3} "
end
```

## Note lengths

Default note length is a whole note, meaning 1.0 sleep after the note is played. Note lengths can be changed with the note length characters, fractions, list notation or escape characters.

Note length definition is always sticky, meaning you only have to type note length once when you need to change the length of the following melody. For example note lengths in Blue bird song can be defined using characters **w** and **q** for Whole and Quarter notes:

```
zplay "q5353 5653 4242 4542 5353 5653 w5 q5432 w1"
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

Same note lengths can also be defined using different escape notations.

### Z escape notation

```
zplay "5353 5653 4242 4542 5353 5653 Z1 5 Z0.25 5432 Z1 1"
```

### Fractions

```
zplay "1/4 5353 5653 4242 4542 5353 5653 4/4 5 1/4 5432 4/4 1"
```

**Note that only 1/1*n works. No support fractions where numerator is bigger than 9, eg. 12/64**

### List notation

```
zplay "(5353) (5653) (4242) (4542) (5353) (5653) 5 (5432) 1"
```

List notation divides the previous note length to equal proportions and can be used to create complex patterns:
```
zplay "w (1234) h (1234) q (1234) w (12(34)) h (1(2(3(4))))"
```

#### Triplets

List notation can be used to play triplets, for example:
```
zplay "q 2 6 h (132) q 5 1 h (432)"
```

### Parameters

Default note length can also be changed via parameter, for example:
```
# Plays short efg notes for 1 note per beat.
zplay("123",{release:0.5, sleep: 1})
```

### Custom lengths for degrees

Custom lengths can be assigned to each degree using **lengths** parameter. This can be useful in gerative melodies.

```
zplay "123", lengths: {0=>"h",1=>"q",2=>"h",3=>"q",4=>"e",5=>"e",6=>"q",7=>"q",8=>"e"}
```

### Dotted notes

**.** for dotted notes. First dot increases the duration of the basic note by half of its original value. Second dot half of the half, third dot half of the half of the half ... and so on. For example dots added to Whole note "w." will change the duration to 1.5, second dot "w.." to 1.75, third dot to 1.875.


## Parse degrees from note names

You can also use notation based on note names to parse melody the ziffers notation. In order to use note names you have to use **Z** control character, fractions or list notation to define note lengths.

Using **zpreparse**-function to parse note names to degrees:
```
print zpreparse "1/4 cdefg - abg", :e
# Prints "1/4 67123 - 453"
```

Use zplay with note names by defining the **parsekey**. These two play exactly same melody:
```
zplay "|:1/4 1231:|:34 2/4 5:|@:1/8 5654 1/4 31:|:1 -5+ 2/4 1:@|", key: :e
zplay "|:1/4 cdec:|:ef 2/4 g:|@:1/8 gagf 1/4 ec:|:c -g+ 2/4 c:@|", parsekey: :c, key: :e
```

## Rest or silence

Use **r** to create musical rest in the melodies. r can be combined with note length, meaning it will sleep the length of the r, for example:

```
# Play quarter note 1 (D) and then sleep half note and then play half note 2 (E)
zplay "q 1 h r 2", key: :d
```

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
zplay "|: 1231 :|: 34w5 :|: q5654h31 :|: 1_5^w1 :|"
```

### Alternative sections or numbered endings

Use **;** in repeats for alternative sections, like "|: 123 ; 432 ; 543 :|".

Alternative endings in ievan polkka:

```
zplay "|:q1e11q12| q3113 |;q2_77^2 |q31h1;q.5e4q32|q31h1:|"\
      "|:q5e55q43|q2_77^2|;q4e44q32|q3113;q4e44q32|q31h1:|", :g, :minor
```

### D.S repeat

Use **@ ... @** to repeat multiple sections. For example this play row row row your boat 2 times and then the last section 2 times at the end:

```
zplay "|:.1.1|1q2h.3|3q2h3q4|w.5|@q888555333111|5q4h3q2|w.1:@|"
```

### Jump repeat, D.C:ish

Use **\*** to start from beginning and continue until first **\***. If & is at the end it works like D.C, otherwise the song will continue after the & character. For example:

```
zplay "| 7162 *| 6354 |*"
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
- **I** = :pitch
- **K** = :key

## Pan

Use P1, P1 or P-1

# Slide

**~** starts and ends the slide. Remeber to add slide speed or/and space after the first slide marker.

For example:
```
zplay "~ 123456789"
# Note slide set to 0.4
zplay "~0.4 12321 "
```

(TODO: release and sleep not working after the note_slide)

# Randomization and generation

With randomization you can create random or semirandom melodies, for example:

```
zplay " |: ???0???q(1,2)[6,7](1,2)[6,7] (1,2)[6,7](1,2)[6,7] :| "
```

## Random note

Use **?** for random degree between 1-7

## Random between
```
zplay "(1,5)" # Random numer between 1 and 5

zplay "(1,7)" # Same as ?

zplay "(1,4)*4" # Random numbers between 1 and 4: "2341"

zplay "(3000,4000)^qeee*4"  # Create 4 random numbers between 3000 and 4000: "q3e532"
```

## Sequences / Pitch sets
Create sequences of pitches using (..1234) or (1..4) notation:
```
zplay "(..13425)" # Just the sequence: 13425

zplay "(1..7)" # Sequence from 1 to 7: "1234567"
```

Sequences can be manipulated using following commands:

**? = Randomize / take random n**
```
zplay "(1..7)?" # Sequence in random order: "2135764"

zplay "(1..7)?3" # Sequence from 1 to 7 take random 3: "152"

zplay "(13467)?2" # Take random 2: "36"
```

**+ = Step**
```
zplay "(1..9)+2" # Sequence from 1 to 9 using step 2: "13579"

zplay "(1..9)+2?3" # Can be combined with take random

```
**% = mirroring**
```
zplay "(1..3)%m" # Mirroring: "123321"

zplay "(1..3)%r" # Reversing: "12321"

zplay "(1..3)%s" # Reversing skipping the last: "1232"
```

**^ = note lengths**
```
zplay "(1..4)^qe" # With note lengths: "q2e2q3e4"

zplay "(..12345)^qe" # With note lengths: "q1e2q3e4q5"

zplay "(1..9)+2?3%m^qeq" # Can be combined with step, take random and mirroring
```

**\* = do n-times**
```
zplay "(1..3)%s*2" # Reversing sequence two times: "12321232"  

zplay "(1..3)?*3" # Create 1..3 in random order 3 times

zplay "(1..7)+2?%r^eqe*3" # Go crazy with the combinations.
```

**NB!**

Combinations are always processed in following order: + ? % ^ \*

Sequences can also be useful with arpeggios, see **arpeggios_example.rb**.

## Choose random from array

Use [q1,e2345,h3] for randomly selected lengths and degree/degrees from the array.
```
zplay "[1,4,6,7]*4" # Choose from array 4 times

zplay "[(1,3),(1..5,2)]" # It is also possible to combine any other ziffers syntax inside the choose array
```

## Variable assignation

Ziffers notation can be assigned to a variable using <{variable_name}={ziffers}> notation. This allows you to assign larger piece in single character and create patterns using those variables. Variables can also be assigned with chance using <{chance}%{variable_name}={ziffers}!={ziffers}> notation.

Examples:
```
zplay "<a=1234><b=321>abab"

zplay "<a=(1..3)%s><b=(-2..1)%s>aabb"

zplay "q<0.5%a=1><0.5%b=3><0.5%c=3>abc" # 50% chance to appear

zplay "<0.5%p=q1234!=q4321>p" # 50% chance to be q1234 or q4321
```

# Chords

Chords can be played using roman numerals: i ii iii iv v vi vii

```
zplay "|: i vi v :|" # Play chords as a sequence using default chord length of 1

zplay "|: iv 123 iii 234 ii 432 i 123 :|", chord_sleep: 0 # Play chord simultaniously with the melody using **chord_sleep**
```

Custom chords can be played using custom chord syntax **{1,3,5}** or in simultanious mode **zplay "135", groups: true**.

Chord key is assigned with **key** parameter (defaults to major). Alternatively **chord_key** can be used to change the key for the chords.

Chords can be customized by taking more notes from the scale or by using chord names.

Examples using the scale:
```
# * multiply the chord notes by octave
# / take n notes from the scale
zplay "i"   # Plays trichord, same as i/3
zplay "i/1" # Plays root
zplay "i/4" # Plays 7th chord
zplay "i/5" # Plays 9th chord
```

For using chord names see **Sonic Pi:s chord and chord_names** in help. Notice that current key is ignored if the chord_name is used. Set chord name for all chords using **chord_name** or for single chords using **^**.

Examples using the chord names:
```
zplay "i vi", chord_name: :dim
zplay "i vi^dim"
zplay "i vi", chord_name: "m11+"
zplay "i vi^m11+"
zplay "i^maj*2" # Plays chord in two octaves
```

Chords can also be inverted using % char, for example %1 to invert all following chords up by one:
```
zplay "%-2 vii %-1 iii vi %0 ii v %1 i %2 iv", chord_sleep: 1, key: :d, scale: :minor

```

## Arpeggios

You can also create melodies by playing chord arpeggios using G character and chords. You can use subset of ziffers notation to denote chord notes and note lengths (other than that will probably break horribly). Arpeggio subset can be escaped using **'** right after the **G** character. Escaping is useful especially if combined with the note grouping.

Examples:

```
zplay "Gq1231 i ii iii iv v vi vii"

zplay "Gq12e^3212 |: i^7 :3||: %-1 iv^dim7 :3|", key: :d4, scale: :mixolydian

zplay "G'q1 234' |: i^7 :4||: %-1 iv :4|", groups: true # Plays root from the chord and then rest of the chord
```

# Ziffers methods

## zplay

Plays degrees in some key and scale. Function plays the hash array from **zparse** or parses the string or array first. You should consider preparsing the melody using **zparse** if you are using **zplay** inside **live_loop**.

**zplay** works with strings, integers and arrays, for example:

```
zplay 1 # Plays in :c :major
zplay [1,2,3], key: "f", sleep: 0.25
zplay "w1h2q3"
zplay [[1,1],[2,0.5],[3,0.25]] # Is same as w1h2q3
```

It can also play samples, use samples as synths and send MIDI out messages. Run [examples](https://raw.githubusercontent.com/amiika/ziffers/master/play_tests.rb) in buffer to see various ways to use zplay.

### MIDI out for external synths and keyboards

Use **port** and **channel** parameters to play external keyboards or virtual synths.

```
zplay "(123..456)?", scale: :hex_sus, port: "loopmidi", channel: 3
```

### Using sample as a synth

You can also use **zplay** with samples to create new "synths" where **zplay** uses Sonic Pi's pitch or rate parameters to play the degrees. Sample length is kept the same by default, which also affects the produces sound. Alternatively use **rate_based** pitch altering that will also change the sample length.

Note lengths do not affect the sample length by default. Samples can be cut to note length using **cut** where the value is the multiplier for the actual note length, meaning 1 means same as the actual note length and for example 0.95 means slightly less. etc.

Examples:
```
# Pitch based (default)
zplay "554e56 12323456 q 334e56 e75645343", sample: :guit_e_fifths, start: 0.2, finish: 0.25, amp: 3
zplay "554e56 12323456 q 334e56 e75645343", sample: :guit_e_fifths, start: 0.2, finish: 0.25, amp: 3, cut: 1

# Rate based compared to pitch based
zplay "|:q1231:|:q34h5:|@:e5654q31:|:q1_5^h1:@|", sample: :ambi_drone, key: "c1", sustain: 0.25, rate_based: true
zplay "|:q1231:|:q34h5:|@:e5654q31:|:q1_5^h1:@|", sample: :ambi_drone, key: "c1", sustain: 0.25, rate_based: true, cut: 0.5
zplay "|:q1231:|:q34h5:|@:e5654q31:|:q1_5^h1:@|", sample: :ambi_drone, key: "c1", sustain: 0.25
zplay "|:q1231:|:q34h5:|@:e5654q31:|:q1_5^h1:@|", sample: :ambi_drone, key: "c1", sustain: 0.25, cut: 1
```

### Playing with custom character mapping

Ziffers *zplay* can also play rhythms and melodies using custom samples or midi mapping. All capital characters can be assigned for sample use in root level or via **use** parameter. Note that some characters may overwrite other control characters like 'A', but it doesnt matter if you are not using that control character.

```
zplay "|: X O e XX q O :4|", X: :bd_tek, O: :drum_snare_soft # Assign X and O for samples

zplay "|: X O e XX q O :4|", use: {"X": :bd_tek, "O": :drum_snare_soft} # Same using **use** parameter

zplay "|: O q X X X X :4|", X: :bd_tek, O: {sample: :ambi_choir, rate: 0.3, sleep: 0} # Sleep and other sample opts can be defined in hash

n = {
  B: :bd_tek,
  K: :drum_snare_soft,
  H: {sample: :drum_cymbal_closed, amp: 0.2}
}

zplay "(B H) (B (H H)) (BK H) ((BK B) H)", groups: true, use: n # Reuse existing sample or midi mapping

zplay "(B H) (B (H H)) (BK H) ((BK B) H)", B: 60, H: 70, K: 90, groups: true, port: "loopmidi" # Use midi mapping
```

### Custom Samples

Custom samples can be used with direct path or with **sample_dir** parameter and number of the sample:
```
zplay "1 2 3 4", sample: "~/samples/Jungle/Vocals/Bad Boy.wav"
zplay "1 2 3 4", sample_dir: "~/samples/Jungle/Vocals/", sample: 1 # Gets first sample from the directory
```

## zloop

zloop is just a shorthand for **live_loop** and can be played with the same parameters. By default ziffers syntax is preparsed before the loop is started, meaning the same melody will repeat. Alternatively you can use the *seed* parameter to define the random seed for the loop, which will also randomize the content for the every run.

Other than being short and cool, **zloop** and **z0-20** also work better with Markov chains and lsystem **rules**.

Example loops:
```
zloop :bass, "(r D r (D D))", D: :bass_woodsy_c
zloop :beat, "(B H (B B) H)", B: :drum_bass_soft, H: :drum_cymbal_closed, sync: :bass

```
is equivalent to:
```
live_loop :beat do
  zloop :bass, "(r D r (D D))", D: :bass_woodsy_c
end
live_loop :beat, sync: :beat do
  zplay "(B H (B B) H)", B: :drum_bass_soft, H: :drum_cymbal_closed
end
```

Creating randomizing loop with seed:
```
zloop :rnd, "q [1324,2435,4657] e (1..8)?", seed: 1
```

Loops can be stopped by commenting out the content like:
```
zloop :foo, "//4321"
```

It is also possible to use predefined mapping with **use** parameter and predefined loops **z0-z20**.

Example
```
s = { B: :bd_fat, H: :drum_cymbal_closed, C: :bass_voxy_hit_c } # Predefined sample mappings

zloop :beat, "q B H (B B) H", use: s # Named loop

z1 "q B H (B B) H", use: s # Predefined loop :z1

z2 "(r (C C) r (C C) )", use: s # Predefined loop :z2
```

### z0 - z20

There are 20 prenamed loops **z0** to **z20** which are just shorthands for **zloop** (Because you need shorthands for shorthands).

Example:
```
z1 "| h (BH r H) (H r BH) | (BS H S) (HB r (H H)) |", groups: true, B: :drum_bass_hard, H: :drum_cymbal_closed, S: :drum_snare_soft
```

## Run with Effects

Ziffers methods like **zplay**, **zloop**, **z1** etc. can be run with Sonic Pi FX effects (and some other blocks) by defining **run** array.

Run works with effects and following block. See parameters from Sonic Pi:s documentation.

* with_fx
* with_bpm
* with_swing
* with_cent_tuning
* with_octave

Example:
```
zplay "|:q1234 8 4321:|", run: [
  {with_bpm: 120},
  {with_fx: :echo},
  {with_fx: :bitcrusher, bits: 5 }
]
```

Effects can also be applied to single samples:
```
z1 "B K (B B) K",
  run: [{with_bpm: 120}],
  use: {
    B: :bd_fat,
    K: { sample: :drum_snare_soft, run: [{with_fx: :echo}] }
  }
```

Or all of the samples:
```
z1 "B K (B B) K",
  run: [{with_bpm: 120}],
use: {
  B: :bd_fat,
  K: { sample: :drum_snare_soft },
  run: [{with_fx: :echo}]
}
```

## zmidi

Plays midi notes using space separated midi notation:

```
zmidi "|: q 53 53 53 57 h 60 q 53 53 ; h 55 q 60 60 h 57 q 53 53 ; q 55 55 57 55 w 53 :|"
```

Midi can also be sent to virtual synths to play melody or drums, for example:
```
zmidi "|: q 12 90 e 12 12 q 90 :6|", port: "loopmidi", channel: 1
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

Ziffers can be used to generate fractal melodies using L-system based approach. Define transformation **rules** as hash object and use **gen** parameter to define amount of generations the rules are run against.

Matched values are defined as hash keys and replacements as hash value. For example:
```
zplay "1", rules: {"1"=>"13","3"=>"6431"}, gen: 3
```

Key can be string or regular expression that represents the string to be matched and replaced. You can feed back the matched string with $ or ${1-9} if using regexp groups. Use single quotes to evaluate the calculations:

```
zplay "1", rules: {/(3)1/=>"q'$1+1'1'$1+2'",/[1-7]/=>"e313"}, gen: 4
sleep 2
zplay "123", rules: {/[1-9]/=>"'$*1' [e,q] '$*2'"}, gen: 4
```

## Stochastic rules

Stochastic rules can be written using the ziffers **random syntax** or **variable syntax** to define different chance of replacement. This way you can vary the replaced matches when using alternative random seeds:
```

zplay "q1234", rules: {"1"=>"<0.2%a=(1..9)?6!=1>a"}, gen: 9
zplay "q1234", rules: {/[1-7]/=>"<0.2%a=(1..7)?!=$>a"}, gen: 3
```

## Context dependent rules

Use regular expression lookbehind and lookahead syntax. For example this would match 3 only if it is between 1 and 2:
/(?<=1)3(?=2)/

## Generation specific rules

Use Array or Ring to indicate which generation the rules will affect, for example:

Rules for first and third generations only:
```
zplay "1234", rules: {"3"=>["73",nil,"94"]}, gen: 6
```

Rules for every third generation:
```
zplay "1234", rules: {"3"=>(ring nil, nil,"123")}, gen: 6
```

## Markov chains and automata rules

Markov chains can also be created using the **rules** that will produce next set of notes in a way that the end result does not grow. This type of rule somewhat similar to cellular automata.

This type of rules can be played in a loop, for example:
```
z1 "q1", seed: 1, rules: {
  "1"=>"2",
  "2"=>"3",
  "3"=>"[1,2]"
}
```

Note that use of **seed** is mandatory with this type of rules in a loop. Alternatively you can define **gen**, but the loop then plays only that given generation.

Notice that editing the rules and running the code again wont start automatically from the first generation. Use **reset** to if you want to start from the beginning when running the code.

Example with reset:
```
use_synth :chipbass

z1 "q12e3456", reset: true, seed: 3, rules: {
  "1"=>"[2,4]",
  "2"=>"[1,5]",
  "3"=>"5",
  "4"=>"3",
  "5"=>"[1,3]"
}
```

Same thing can also be done using **lsystem** and live_loop:
```
use_synth :chipbass

n = lsystem("12e3456",{"1"=>"[2,4]","2"=>"[1,5]","3"=>"5","4"=>"3","5"=>"[1,3]"},10).ring

live_loop :p do
  sample :bd_tek
  zplay n.tick
end
```
