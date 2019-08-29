load "~/ziffers/ziffers.rb"

use_bpm 80

disco1 = "|: zHqB H | zHSqB H :|"
disco2 = "| zHqB H | zBSqH zBqH |"
disco3 = "| zHeB HHH | zSHeB HHH |"
house1 = "|: zHqB H |; zBSqS H |; zBSqH eHS:|"
house2 = "| zHqB H | zBSqH H | zHqB eSH | zBS qSH |"
house3 = "| zHqB H | zBSqH eHS | zHqB H | zBSqH zBqH |"

rythm = zparse disco1*2+disco2*2+disco3*2,
samples: {
  B: :bd_tek,
  S: :drum_snare_soft,
  H: {sample: :drum_cymbal_closed, opts: {amp: 0.3}}
}

live_loop :beat do
  zplay rythm
end

