load "~/ziffers/ziffers.rb"

# Musical dice game: https://en.wikipedia.org/wiki/Musikalisches_W%C3%BCrfelspiel

use_bpm 18
use_synth :piano
use_random_seed 987654365787

tremble =  ["e 3 1 4", "e _5 s _#3 _4 _6 4", "e 4 0 2", "e 4 q 1", "q _4_614 e r", "e _4 0 2", "s 2 0 2 4 ^0 4", "q 0 e r", "e 02 _61 r", "s _6 _5 _6 0 1 _6", "s 2 0 _6 _5 _4 _#3", "e _20 _20 _20", "e 0 _4 _2", "q 0 e r", "e 2 s 4 2 e 0", "e 5 #3 1", "s 0 _4 0 2 _4 0", "e _4 0 2", "s 2 0 e 2 4", "e 4 s 6 ^1 e 1", "s 0 2 4 1 _5 #3", "e 2 0 _4", "s 3 2 1 2 3 4", "q _4_614 e r", "s _1 _#3 _5 1 #3 5", "e 02 02 02", "s 3 2 3 1 0 _6", "s #3 1 _5 5 #3 1", "s _6 1 4 1 e _6", "q _4_614 e r", "s 2 0 e _4 2", "e _4 0 3", "q _4_614 e r", "s 2 0 1 _6 e _4", "e _5 1 #3", "s _5 2 1 4 #3 5", "s 4 6 4 1 e _6", "e 0 _4 2", "e 4 _4 _4", "s 0 _6 0 2 _4 0", "s 0 _6 0 2 e _4", "s _6 0 1 _6 _5 _4", "e 4 s 3 2 1 0", "e _5 s 3 1 _5 _6", "s 0 _6 0 _4 _2 _0", "e 4 s 6 4 1 _6", "e 4 s 4 1 e 6", "e 2 s 0 2 4 ^0", "e 2 _6 _4", "e 0 s 2 0 e _4", "s 0 _4 2 0 4 2", "s 1 #0 1 3 _4 _6", "e 02 s 02 13 e 24", "e _20 _20 _20", "e 4 6 1", "s 1 _6 e _4 r", "e 2 0 _4", "e 4 2 0", "e 4 0 2", "e 4 s 3 2 1 0", "e 0 s 2 0 e 4", "s 2 0 _6 _4 _5 _#3", "s 2 0 _6 0 e _4", "s 2 4 ^0 4 2 0", "s 1 _5 e 1 #3", "e 3 5 3", "s 0 _6 0 2 _4 0", "e 4 s 6 5 1 4", "e 4 3 0", "e #3 s 5 #3 1 #3", "s 4 6 ^1 6 e 4", "s 3 2 1 0 _6 1", "e 4 2 0", "s ^0 6 ^0 4 2 0", "e 1#3 1#3 1#3", "s ^0 6 ^0 4 2 0", "s 4 6 e 4 1", "e 0 _0 r", "q 0 e r", "e 1 _5 #3", "q _4_614 e r", "s 1 _6 e _4 4", "q 0 e r", "s 0 _4 2 0 4 2", "e 0 2 _4", "e 1 s 1 4 e 6", "e 4 0 2", "s 4 1 4 6 4 1", "s 3 2 e 1 4", "s #3 5 ^1 5 #3 5", "q _4_614 e r", "e _61 s 4 6 e 1", "q 0 e r", "q _4_614 e r", "e 4 2 0", "e 2 0 _4", "s 4 #3 4 1 _6 _4", "e 0 _4 2", "e #3 5 1", "q _4_614 e r", "s 2 1 2 4 ^0 4", "s #3 1 e _5 #3", "s 0 2 0 _4 e _2", "s 2 1 2 4 ^0 4", "e #3 s 5 #3 1 #3", "e _5 s 1 0 _6 _5", "q _4_614 e r", "e 2 4 ^0", "s 1 3 1 3 _6 1", "s _61 _50 _50 _4_6 _4_6 _#3_5", "q 0 e r", "e 2 0 _4", "e 3 1 _6", "e _61 _61 _61", "s _5 _4 2 0 4 2", "s 1 3 5 3 1 _6", "s 1 _5 1 #3 5 #3", "s 2 5 4 6 #3 5", "s 2 0 4 2 ^0 4", "e ^1 s 5 #3 1 _5", "e 4 s 6 4 e 1", "s 4 #3 4 6 e 1", "q _4_614 e r", "e _20 _20 _20", "s 4 2 1 _6 e _4", "s 0 _4 0 2 4 02", "q _4_614 e r", "e _6 1 4", "s 5 4 #3 4 e 1", "e _20 _20 _20", "q 0 e r", "e 02 s _61 _4_6 e _4", "e 1 s 4 1 _6 1", "s _5 2 _61 _50 _4_6 _#3_5", "e #3 s #3 1 e 5", "s ^0 6 ^0 4 2 0", "e 0 _4 2", "e _51#3 q 4", "s 4 6 4 6 e 1", "e 0 s 0 1 e #3", "s 1 2 3 1 0 0", "e 0 _4 2", "e 4 s 1 _6 e _4", "e 4 0 2", "s 1 3 _5 1 _6 1", "e _#31 1#3 #35", "s 2 ^0 6 4 5 #3", "s ^0 6 ^0 4 2 0", "s 3 1 e _5 _6", "e _402 q 2", "q 0 e r", "e 4 s 3 2 1 0", "s 1 _5 #3 1 5 #3", "s 1 #0 1 #3 5 #3", "s 4 6 4 1 _6 _4", "s 0 _4 2 0 e 4", "s 2 1 2 4 ^0 4", "e _6 s 1 _6 _5 _4", "s 2 4 1 0 _6 _5", "s 0 _6 0 2 _4 0", "e _#31 _#31 _#31", "s 2 1 2 4 ^0 4", "s 4 #3 4 1 _6 _4", "e 1 q _4", "e 1 _6 _4", "s 0 6 4 1 e _6", "e 0 s 0 1 e 2", "e 4 s 3 2 1 0", "s 2 4 1 4 _5 #3", "q 0 e r", "s _6 0 1 2 3 1", "q 0 e r", "s 3 5 e _4 s _6 1", "e _4 0 2", "s 2 0 _6 1 e 4", "s 5 4 6 4 1 4"]
bass = ["e 3 1 4", "q _64 e r", "q 02 e r", "s _4 _6 e 4 _6", "e _4 s 46 34 2#3 12", "q 02 e r", "q 04 e r", "e 0 _4 _0", "q 4 e _4", "q 4 e r", "e 0 1 _1", "e 0 0 0", "q 24 e r", "e 0 _4 _0", "q 04 e 02", "q 1#3 e 0#3", "q 24 e r", "q 02 e 04", "q 04 e 02", "q 1 e r", "e 0 1 _1", "q 0 e r", "s 3 2 1 2 3 4", "e _4 s 46 34 2#3 12", "q 1 e 0", "s 0 2 4 2 ^0 0", "q 46 e r", "q 05 e r", "q 4 e _4", "e _4 s 46 34 2#3 12", "q 04 e 04", "q 02 e r", "e _4 s 46 34 2#3 12", "q 4 e r", "q 1#3 e 05", "e 0 1 _1", "q _61 e r", "s 02 4 02 4 02 4", "s _6 1 4 1 _6 _4", "q 02 e r", "q 02 e r", "q _4 e r", "q 02 e r", "q 3 e 4", "q 24 e r", "q _61 e r", "q _61 e r", "q 04 e 02", "s 02 4 02 5 02 4", "q 24 e r", "q 02 e r", "q 3 e 4", "q 0 e r", "e 0 0 0", "q _61 e r", "q _44 e 4", "s 02 4 02 4 02 4", "s 02 4 02 4 02 4", "s 02 4 02 5 02 4", "q 02 e r", "q 24 e r", "e 0 1 _1", "q 0 e r", "q 04 e 04", "q 1#3 e r", "e 15 1#3 01", "q _62 e 24", "q _6 e r", "q 02 e r", "q 1 e 0", "q _61 e _61", "q 3 e 4", "s 02 4 02 4 02 4", "q 02 e r", "e 0 0 0", "q 02 e 04", "q _61 e _64", "q 0 e _0", "e 0 _4 _0", "q 0 e r", "e _4 s 46 34 2#3 12", "q _64 e _61", "e 0 _4 _0", "q 02 e r", "q 24 e r", "q _64 e r", "q 02 e 04", "q _61 e _61", "s 3 2 e 1 4", "q 05 e 05", "e _4 s 46 34 2#3 12", "q _44 e 4", "e 0 _4 _0", "e _4 s 46 34 2#3 12", "q 02 e r", "q 0 e r", "q _61 e _64", "s 02 4 02 4 02 4", "q 05 e 05", "e _4 s 46 34 2#3 12", "q 04 e 02", "q 05 e 05", "q 24 e r", "q 0 e r", "q 0 e r", "e 0 1 _1", "e _4 s 46 34 2#3 12", "q 04 e 02", "q 35 e 4^1", "e 0 1 _1", "e 0 _4 _0", "s 02 4 02 4 02 4", "q 46 e r", "e 4 4 4", "q 02 e r", "q 3 e 4", "q 1#3 e r", "e 0 1 _1", "q 02 e r", "q 1#3 e 0#3", "q _64 e r", "e _61 _61 _64", "e _4 s 46 34 2#3 12", "e 0 0 0", "e 4 _4 r", "q 2 s 2 0", "e _4 s 46 34 2#3 12", "q _4 e r", "e _61 _61 _64", "e 0 0 0", "e 0 _4 _0", "e 4 _4 r", "q _64 e r", "e 0 1 _1", "e 01 01 01", "q 02 e r", "s 02 4 02 4 02 4", "s _1 1 #0 1 0 1", "q _6 e r", "e 0#3 0#3 05", "q _64 e _4", "q 02 e r", "q _61 e _61", "s 02 4 02 4 02 4", "q 3 e 4", "e 0 0 0", "e 0 1 _1", "q 02 e r", "q 3 e 4", "s 0 _6 0 1 2 #3", "e 0 _4 _0", "q 02 e r", "q 0 e r", "q 0 e r", "q _61 e r", "q 24 e r", "q 0 e r", "q _4 e r", "e 0 1 _1", "q 02 e 02", "e 0 0 0", "q 04 e 02", "q _61 e r", "s 4 #3 4 1 _6 _4", "q _6 e r", "q 46 e r", "q 02 e r", "q 02 e 24", "e 1 1 _1", "e 0 _4 _0", "q _44 e _64", "e 0 _4 _0", "q 3 e 4", "s 02 4 02 4 02 4", "e 4 _4 r", "q _61 e _61"]

live_loop :dice_game do
  r = rrand_i 0,175
  print tremble[r]
  print bass[r]
  
  in_thread do
    zplay bass[r], octave: -1
  end
  
  zplay tremble[r], octave: 1
  
end

