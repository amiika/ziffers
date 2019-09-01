load "~/ziffers/ziffers.rb"

use_bpm 100

Ziffers.setSimultanious true

breakbeat = "| h HB H | h HS q H B | q H B H B  | h HS q H B  |
             | h HB H | h HS h H | q H H r B | h HS q H H |"

rythm = zparse breakbeat,
samples: {
  B: :bd_tek,
  S: :drum_snare_soft,
  O: {sample: :drum_cymbal_open, opts: {amp: 0.3}},
  H: {sample: :drum_cymbal_closed, opts: {amp: 0.2}}
}

live_loop :beat do
  zplay rythm
end

live_loop :bass do
  zplay "hr1r1 r2r2", key: 30
end



