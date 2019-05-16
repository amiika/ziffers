require "~/ziffers/ziffers.rb"

use_bpm 120

# Progression: I-V-vi-iii-IV-I-IV-V
pachels = zparse("i %-2 v %-3 vi iii iv i %-2 iv Z0.0 v", key: 66.7, chordSleep: 1, chordRelease: 1, scale: :ionian)

live_loop :clock do
  sleep 1
end

live_loop :chords do
  sync :clock
  with_fx :wobble, phase: 0.5, wave: 3, probability: 0.5  do
    # Note Z0.0 in last chord / note when syncing
    zplay(pachels)
  end
end

live_loop :beat do
  sync :clock
  sample :bd_mehackit
  sleep 1
end
