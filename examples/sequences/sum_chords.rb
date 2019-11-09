load "~/ziffers/ziffers.rb"

# To infinity and beyond!

inf = (1..Float::INFINITY)
e = inf.lazy.collect {|x| (x*x).to_s }

zplay e

#n = inf.step(7).take(3).inject(&:+)
