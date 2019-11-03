require "~/ziffers/ziffers.rb"

use_bpm 130

# TODO: Fix this example

live_loop :melody do
  with_fx :reverb, room: 0.5 do
    with_fx :flanger, phase: 1, depth: 1, delay: 0.5 do
      with_synth :sine do
        zplay("|: i _ q5555 4331 h 1123 v 4432 5534 ^ :|:i h 5432 [????,1324] v 5432 [7765,????]:|: _ 9987 8786 7675 6656 ^ :|:i h [????,1425] v q 46576989 iv h [????,4231] q 75645342 :|", amp: 0.5)
      end
    end
  end
end

live_loop :beat do
  zdrums("1")
  sleep 1
end

live_loop :bass do
  sleep 0.5
  with_synth :fm do
    zplay("_ 1 1", key: 55, scale: :minor_pentatonic, amp: 2)
  end
end
