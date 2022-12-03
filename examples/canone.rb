
load "~/ziffers/ziffers.rb"

use_bpm 120

a = zparse "| q. _ 0 e 0 q 1 e 2 2  | C q _ 3 3 2 e 2 2  | q _ 1 h 4 q 3  | e r s _ 4 3 e 2 s 3 2 h 1  | q. _ 0 e 0 q 1 e 2 2  | w _ 3 |", C: {cue: :foo }

b = "| q. _ 0 e 0 q 1 e 2 2  | q _ 3 3 2 e 2 2  | q _ 1 h 4 q 3  | e r s _ 4 3 e 2 s 3 2 h 1 | w _ 3 |"

z1 a, synth: :piano, scale: :minor, inverse: -1

z2 b, wait: :foo, scale: :minor, synth: :piano, transpose: -3, retrograde: true, inverse: 2
