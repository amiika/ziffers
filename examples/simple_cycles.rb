load "~/ziffers/ziffers.rb"

z1 "q 1 2 3 4", key: :g, seed: 1,
cycle: [
  { at: 2, offset: ->(i){i%10}, inverse: true },
  { at: 4, first: 2, retrograde: 2, inverse: -1 },
  { at: 8, from: 6, to: 7, inverse: 3 }
]
