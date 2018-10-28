use_synth :fm

z = zparse "111525"

live_loop :faster do
  zplay z
end

live_loop :slower do
  zplay z, {},sleep: 0.95, release: 1.05
end