load "~/ziffers/ziffers.rb"

use_bpm 140
royal_theme = zparse "h 0 2 | 4 5 | #-1 q r 4 | h #3 3 | #2 b2 | q 2 1 b1 0 | q #-1 e #-2 #-3  q 0 3 | h 2 1 | w 0 |", scale: :minor

z0 royal_theme, synth: :piano
z1 royal_theme, phase: 0.15, synth: :kalimba
z2 royal_theme, phase: 0.25, synth: :piano, octave: -1: :fm, octave: -1
