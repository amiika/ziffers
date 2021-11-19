load "~/ziffers/ziffers.rb"

z1 "q 1 2 3 4", key: :g, seed: 1,
cycle: [
  { mod: 2, offset: ->(i){i%10}, inverse: true },
  { mod: 4, first: 2, retrograde: 2, inverse: -1 },
  { mod: 8, from: 6, to: 7, inverse: 3 }
]
