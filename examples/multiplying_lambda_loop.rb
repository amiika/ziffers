load "~/ziffers/ziffers.rb"

use_bpm 200

z1 "q1 e3 q4", seed: 1, rules: {
  /([a-z])*([1-9]*)/=> ->(i,m){ m[1]+(m[2].to_i*2%7).to_s }
}
