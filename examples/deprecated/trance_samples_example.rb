load "~/ziffers/ziffers.rb"

use_bpm 120

live_loop :ambient do
  with_synth :dark_ambience do
    zplay "d3 6 5 q1 w7 4", scale: :mixolydian
  end
end

live_loop :beat do
  zplay "|: h O q X X :7| q X X OX OX |",
  samples: {
    "O": :bd_tek,
  "X": {sample: :bass_thick_c, opts: {slice: 0}}}
end
