load "~/ziffers/ziffers.rb"

use_bpm 200

live_loop :te do
  zplay "q 4 4 3 e 4 5 0 1 2 1 2 3 4 5 q 2 2 3 e 4 5 [q 6 6 5 4,e 6 4 5 3 4 2 3 2,e (0..8)~]", sample: :drum_cowbell, rate_based: true
end
