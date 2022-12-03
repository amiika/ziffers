
use_bpm 60
melody = zparse "0..6"
octaves = [0,-2,1,-1,2,0,1]

# Deal melody to 5 parts (Like dealing cards)
parts = melody.deal 5

12.times do
  melody.length.times do |i|
    parts.each_with_index do |z,j|
      zplay z[i], octave: octaves[i+j], synth: :hollow, sustain: 6.0, decay: 4.0, duration: rrand(0.5,1.5)  if z[i]
    end
  end
  octaves = octaves.shuffle
end
