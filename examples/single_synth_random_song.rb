require "~/ziffers/ziffers.rb"

live_loop :boom do
  zdrums("1 r r 1",{key: :c,scale: :minor})
end

live_loop :melody do
  zplay("i ???? iii ???? v ????",{key: :c,scale: :minor})
end

live_loop :bass do
  zplay("q(1,3)(1,3)(2,4)(2,4)",{key: :c,scale: :minor, pitch: -12})
end

live_loop :slide do
  zplay("~ ????",{key: :c,scale: :minor})
  sleep rrand_i(3,6)
end
