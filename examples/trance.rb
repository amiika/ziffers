require "~/ziffers/ziffers.rb"

use_bpm 100

print Ziffers.durations

live_loop :ambient do
  with_synth :dark_ambience do
    zplay "d365q1w74", scale: :mixolydian
  end
end

live_loop :drums do
  zplay "|:q O e XX:7| zO eXXXX", samples: {"O": :bd_tek, "X": {sample: :bass_thick_c, opts: {slice: 0}}}
end
